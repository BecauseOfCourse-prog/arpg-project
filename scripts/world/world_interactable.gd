extends Node2D
class_name WorldInteractable

@export var click_radius: float = 22.0
@export var interaction_range: float = 24.0

func _ready() -> void:
	add_to_group("world_interactables")

func interact(_player: PlayerActor, _progression: PlayerProgression, _navigation: NavigationGrid) -> bool:
	return false

func contains_interaction_point(world_point: Vector2) -> bool:
	return global_position.distance_to(world_point) <= click_radius
