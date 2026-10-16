extends CanvasLayer
class_name InventoryController

signal item_clicked(inventory_index: int, sell_entire_stack: bool)

var collected_items: Array[ItemDefinition] = []
const GRID_WIDTH := 10
const GRID_HEIGHT := 4
var item_positions: Array[Vector2i] = []
var item_counts: Array[int] = []
var _progression: PlayerProgression

@onready var _grid_view: Control = get_node_or_null("Panel/Contents/Grid") as Control
@onready var _items_label: Label = get_node_or_null("Panel/Contents/Items") as Label
@onready var _gold_label: Label = get_node_or_null("Panel/Contents/Gold") as Label

func _ready() -> void:
	add_to_group("inventory_controller")
	if _grid_view != null:
		_grid_view.inventory = self
		if _grid_view.has_signal("item_clicked"):
			_grid_view.connect("item_clicked", _on_grid_item_clicked)
	_refresh_display()

func configure_progression(progression: PlayerProgression) -> void:
	if is_instance_valid(_progression) and _progression.gold_changed.is_connected(_refresh_gold):
		_progression.gold_changed.disconnect(_refresh_gold)
	_progression = progression
	if _progression != null:
		_progression.gold_changed.connect(_refresh_gold)
	_refresh_gold(_progression.gold if _progression != null else 0)

func _refresh_gold(amount: int) -> void:
	if _gold_label != null:
		_gold_label.text = "Золото: %d" % amount

func collect_item(item: WorldItem) -> void:
	if item == null or item.definition == null or item.is_queued_for_deletion():
		return
	if not add_item(item.definition):
		return
	item.queue_free()

func can_add_item(definition: ItemDefinition, amount: int = 1) -> bool:
	return bool(_plan_addition(definition, amount).get("fits", false))

func add_item(definition: ItemDefinition, amount: int = 1) -> bool:
	var plan := _plan_addition(definition, amount)
	if not bool(plan.get("fits", false)):
		return false
	item_counts = plan["counts"]
	for position: Vector2i in plan["new_positions"]:
		collected_items.append(definition)
		item_positions.append(position)
	_refresh_display()
	return true

func remove_item_at(index: int, amount: int = -1) -> ItemDefinition:
	if index < 0 or index >= collected_items.size():
		return null
	var definition := collected_items[index]
	var quantity := item_counts[index] if amount < 0 else mini(amount, item_counts[index])
	if quantity <= 0:
		return null
	item_counts[index] -= quantity
	if item_counts[index] <= 0:
		collected_items.remove_at(index)
		item_positions.remove_at(index)
		item_counts.remove_at(index)
	_refresh_display()
	return definition

func find_item_index_by_id(item_id: String) -> int:
	for index in range(collected_items.size()):
		if collected_items[index] != null and collected_items[index].definition_id == item_id:
			return index
	return -1

func restore_items(item_paths: Array, positions: Array, counts: Array) -> bool:
	if item_paths.size() != positions.size() or item_paths.size() != counts.size():
		return false
	var restored_items: Array[ItemDefinition] = []
	var restored_positions: Array[Vector2i] = []
	var restored_counts: Array[int] = []
	var occupied: Array[Array] = []
	for y in range(GRID_HEIGHT):
		var row: Array[bool] = []
		row.resize(GRID_WIDTH)
		row.fill(false)
		occupied.append(row)
	for index in range(item_paths.size()):
		var path := str(item_paths[index])
		if not path.begins_with("res://data/items/") or not path.ends_with(".tres"):
			return false
		if not ResourceLoader.exists(path):
			return false
		var item := ResourceLoader.load(path) as ItemDefinition
		if item == null:
			return false
		if not positions[index] is Array or positions[index].size() != 2 or not _is_whole_number(positions[index][0]) or not _is_whole_number(positions[index][1]) or not _is_whole_number(counts[index]):
			return false
		var origin := Vector2i(int(positions[index][0]), int(positions[index][1]))
		var quantity := int(counts[index])
		var width := clampi(item.inventory_width, 1, GRID_WIDTH)
		var height := clampi(item.inventory_height, 1, GRID_HEIGHT)
		var limit := item.stack_limit() if item.stackable else 1
		if origin.x < 0 or origin.y < 0 or origin.x + width > GRID_WIDTH or origin.y + height > GRID_HEIGHT:
			return false
		if quantity <= 0 or quantity > limit:
			return false
		for y in range(origin.y, origin.y + height):
			for x in range(origin.x, origin.x + width):
				if occupied[y][x]:
					return false
				occupied[y][x] = true
		restored_items.append(item)
		restored_positions.append(origin)
		restored_counts.append(quantity)
	collected_items = restored_items
	item_positions = restored_positions
	item_counts = restored_counts
	_refresh_display()
	return true

func _is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	return value is float and is_equal_approx(float(value), roundf(float(value)))

func _plan_addition(definition: ItemDefinition, amount: int) -> Dictionary:
	if definition == null or amount <= 0:
		return {"fits": false}
	var counts := item_counts.duplicate()
	counts.resize(collected_items.size())
	var remaining := amount
	var max_stack := definition.stack_limit() if definition.stackable else 1
	if definition.stackable:
		for index in range(collected_items.size()):
			if collected_items[index] == definition and counts[index] < max_stack:
				var moved := mini(remaining, max_stack - counts[index])
				counts[index] += moved
				remaining -= moved
				if remaining == 0:
					return {"fits": true, "counts": counts, "new_positions": []}
	var occupied: Array[Array] = []
	for y in range(GRID_HEIGHT):
		var row: Array[bool] = []
		row.resize(GRID_WIDTH)
		row.fill(false)
		occupied.append(row)
	for index in range(mini(collected_items.size(), item_positions.size())):
		var existing := collected_items[index]
		var origin := item_positions[index]
		var item_width := clampi(existing.inventory_width, 1, GRID_WIDTH)
		var item_height := clampi(existing.inventory_height, 1, GRID_HEIGHT)
		for y in range(origin.y, mini(GRID_HEIGHT, origin.y + item_height)):
			for x in range(origin.x, mini(GRID_WIDTH, origin.x + item_width)):
				occupied[y][x] = true
	var width := clampi(definition.inventory_width, 1, GRID_WIDTH)
	var height := clampi(definition.inventory_height, 1, GRID_HEIGHT)
	var new_positions: Array[Vector2i] = []
	while remaining > 0:
		var position := Vector2i(-1, -1)
		for y in range(GRID_HEIGHT - height + 1):
			for x in range(GRID_WIDTH - width + 1):
				var fits := true
				for item_y in range(y, y + height):
					for item_x in range(x, x + width):
						if occupied[item_y][item_x]:
							fits = false
				if fits and position.x == -1:
					position = Vector2i(x, y)
		if position.x == -1:
			return {"fits": false}
		for item_y in range(position.y, position.y + height):
			for item_x in range(position.x, position.x + width):
				occupied[item_y][item_x] = true
		new_positions.append(position)
		var added_count := mini(remaining, max_stack)
		counts.append(added_count)
		remaining -= added_count
	return {"fits": true, "counts": counts, "new_positions": new_positions}

func _refresh_display() -> void:
	if _grid_view != null:
		_grid_view.call("refresh")
	if _items_label == null:
		return
	if collected_items.is_empty():
		_items_label.text = "Inventory: empty"
		return
	var lines := PackedStringArray(["Inventory"])
	for index in range(collected_items.size()):
		var item := collected_items[index]
		var count_text := " ×%d" % item_counts[index] if item_counts[index] > 1 else ""
		lines.append("%s%s (%dx%d) — %s, %s" % [item.display_name, count_text, item.inventory_width, item.inventory_height, item.rarity, item.affix_text])
	_items_label.text = "\n".join(lines)

func _on_grid_item_clicked(inventory_index: int, sell_entire_stack: bool) -> void:
	item_clicked.emit(inventory_index, sell_entire_stack)
