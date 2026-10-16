extends WorldInteractable
class_name WorldItem

@export var definition: ItemDefinition
var collected := false
var _name_label: Label

func _ready() -> void:
	super._ready()
	add_to_group("world_items")
	add_to_group("world_transients")
	_name_label = get_node("ItemName") as Label
	_name_label.text = definition.display_name if definition != null else "Item"
	_name_label.size = _name_label.get_minimum_size()
	_name_label.position = Vector2(-_name_label.size.x / 2.0, -30.0)

func contains_interaction_point(world_point: Vector2) -> bool:
	return super.contains_interaction_point(world_point) or (_name_label != null and Rect2(Vector2.ZERO, _name_label.size).has_point(_name_label.get_global_transform().affine_inverse() * world_point))

func interact(_player: PlayerActor, _progression: PlayerProgression, _navigation: NavigationGrid) -> bool:
	if collected or is_queued_for_deletion() or definition == null:
		return false
	for node: Node in get_tree().get_nodes_in_group("inventory_controller"):
		var inventory := node as InventoryController
		if inventory != null and inventory.get_parent() == get_parent():
			if not inventory.add_item(definition):
				return false
			collected = true
			queue_free()
			return true
	return false
