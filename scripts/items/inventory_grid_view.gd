extends Control
class_name InventoryGridView

signal item_clicked(inventory_index: int, sell_entire_stack: bool)

const COLUMNS := 10
const ROWS := 4
const SLOT_SIZE := Vector2(32, 32)
const GAP := 2.0

var inventory: InventoryController

func _ready() -> void:
	custom_minimum_size = Vector2(COLUMNS * SLOT_SIZE.x + (COLUMNS - 1) * GAP, ROWS * SLOT_SIZE.y + (ROWS - 1) * GAP)
	mouse_filter = Control.MOUSE_FILTER_STOP

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT or not event.pressed or inventory == null:
		return
	var pitch := SLOT_SIZE + Vector2(GAP, GAP)
	var column := floori(event.position.x / pitch.x)
	var row := floori(event.position.y / pitch.y)
	if column < 0 or column >= COLUMNS or row < 0 or row >= ROWS:
		return
	if fmod(event.position.x, pitch.x) > SLOT_SIZE.x or fmod(event.position.y, pitch.y) > SLOT_SIZE.y:
		return
	for index in range(mini(inventory.collected_items.size(), inventory.item_positions.size())):
		var item := inventory.collected_items[index]
		var origin := inventory.item_positions[index]
		if column >= origin.x and column < origin.x + item.inventory_width and row >= origin.y and row < origin.y + item.inventory_height:
			item_clicked.emit(index, event.shift_pressed)
			accept_event()
			return

func _draw() -> void:
	for y in range(ROWS):
		for x in range(COLUMNS):
			var rect := Rect2(Vector2(x, y) * (SLOT_SIZE + Vector2(GAP, GAP)), SLOT_SIZE)
			draw_rect(rect, Color(0.09, 0.1, 0.12, 1), true)
			draw_rect(rect, Color(0.48, 0.5, 0.53, 1), false, 1.0)
	if inventory == null:
		return
	for index in range(mini(inventory.collected_items.size(), inventory.item_positions.size())):
		var item := inventory.collected_items[index]
		var origin := inventory.item_positions[index]
		var top_left := Vector2(origin) * (SLOT_SIZE + Vector2(GAP, GAP))
		var size := Vector2(clampi(item.inventory_width, 1, COLUMNS), clampi(item.inventory_height, 1, ROWS)) * SLOT_SIZE
		size += Vector2((clampi(item.inventory_width, 1, COLUMNS) - 1) * GAP, (clampi(item.inventory_height, 1, ROWS) - 1) * GAP)
		var item_rect := Rect2(top_left, size)
		draw_rect(item_rect, Color(0.27, 0.41, 0.5, 1), true)
		draw_rect(item_rect, Color(0.72, 0.8, 0.84, 1), false, 1.0)
		draw_string(ThemeDB.fallback_font, item_rect.position + Vector2(4, 17), item.display_name.left(12), HORIZONTAL_ALIGNMENT_LEFT, item_rect.size.x - 8, 12, Color.WHITE)
		var count := inventory.item_counts[index]
		if count > 1:
			draw_string(ThemeDB.fallback_font, item_rect.position + Vector2(item_rect.size.x - 25, item_rect.size.y - 3), "×%d" % count, HORIZONTAL_ALIGNMENT_RIGHT, 21, 10, Color(1, 0.9, 0.55, 1))

func refresh() -> void:
	queue_redraw()
