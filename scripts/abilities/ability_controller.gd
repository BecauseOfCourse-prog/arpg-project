extends Node
class_name AbilityController

signal ability_cast

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/combat/ability_projectile.tscn")

@export var player_path: NodePath = NodePath("../Hub/Player")
@export_range(0, 100, 1) var ability_damage: int = 2
@export_range(0.1, 60.0, 0.1) var cooldown_seconds: float = 3.0
@export var projectile_speed: float = 420.0

var player: PlayerActor
var cooldown_remaining := 0.0

func _ready() -> void:
	player = get_node_or_null(player_path) as PlayerActor

func _process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cast_cursor_ability", false):
		cast_cursor_ability()
		get_viewport().set_input_as_handled()

func cast_cursor_ability() -> bool:
	if player == null:
		return false
	return cast_toward(player.get_global_mouse_position())

func cast_toward(target_position: Vector2) -> bool:
	if player == null or cooldown_remaining > 0.0 or get_tree().paused:
		return false
	var offset := target_position - player.global_position
	if offset.is_zero_approx():
		return false
	var projectile := PROJECTILE_SCENE.instantiate() as AbilityProjectile
	if projectile == null:
		return false
	projectile.direction = offset.normalized()
	projectile.speed = projectile_speed
	projectile.damage = ability_damage
	projectile.global_position = player.global_position + projectile.direction * 15.0
	get_parent().add_child(projectile)
	cooldown_remaining = cooldown_seconds
	ability_cast.emit()
	return true
