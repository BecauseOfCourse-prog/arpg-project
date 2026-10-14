extends CanvasLayer
class_name InventoryController

var collected_items: Array[ItemDefinition] = []

@onready var _items_label: Label = get_node_or_null("Panel/Items") as Label

func _ready() -> void:
	add_to_group("inventory_controller")
	_refresh_display()

func collect_item(item: WorldItem) -> void:
	if item == null or item.definition == null or item.is_queued_for_deletion():
		return
	collected_items.append(item.definition)
	item.queue_free()
	_refresh_display()

func _refresh_display() -> void:
	if _items_label == null:
		return
	if collected_items.is_empty():
		_items_label.text = "Inventory: empty"
		return
	var lines := PackedStringArray(["Inventory"])
	for item in collected_items:
		lines.append("%s — %s, %s" % [item.display_name, item.rarity, item.affix_text])
	_items_label.text = "\n".join(lines)
