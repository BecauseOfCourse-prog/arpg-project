extends Node
class_name InteractionController

var player: PlayerActor
var progression: PlayerProgression
var navigation: NavigationGrid
var target: WorldInteractable

func _ready() -> void:
	player = get_node("../Hub/Player") as PlayerActor
	progression = get_node("../PlayerProgression") as PlayerProgression
	navigation = get_node("../NavigationGrid") as NavigationGrid
	player.interaction_requested.connect(_on_interaction_requested)
	player.movement_command_issued.connect(cancel_interaction)
	player.attack_requested.connect(_on_attack_requested)

func cancel_interaction() -> void:
	target = null

func _on_attack_requested(_enemy: EnemyActor) -> void:
	cancel_interaction()

func _on_interaction_requested(interactable: WorldInteractable) -> void:
	target = null
	player.stop_movement()
	if not is_instance_valid(interactable) or interactable.is_queued_for_deletion():
		return
	var path := navigation.find_path(player.global_position, interactable.global_position, false, player)
	if path.is_empty():
		return
	target = interactable
	player.command_move_to(target.global_position)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		target = null
		return
	if player.global_position.distance_to(target.global_position) > target.interaction_range:
		return
	# Use path distance so a nearby target behind a wall cannot be opened remotely.
	var path := navigation.find_path(player.global_position, target.global_position, false, player)
	if path.is_empty():
		return
	var distance := 0.0
	for index in range(1, path.size()):
		distance += path[index - 1].distance_to(path[index])
	if distance > target.interaction_range:
		return
	player.stop_movement()
	var interactable := target
	target = null
	interactable.interact(player, progression, navigation)
