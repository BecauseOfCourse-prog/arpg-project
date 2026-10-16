extends Area2D
class_name WorldItem

@export var definition: ItemDefinition

func _ready() -> void:
	add_to_group("world_items")
	add_to_group("world_transients")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body is PlayerActor:
		return
	for node: Node in get_tree().get_nodes_in_group("inventory_controller"):
		var inventory := node as InventoryController
		if inventory != null:
			inventory.collect_item(self)
			return
