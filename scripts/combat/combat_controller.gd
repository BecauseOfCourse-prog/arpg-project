extends Node
class_name CombatController

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/combat/basic_projectile.tscn")
const EQUIPMENT_SCENE: PackedScene = preload("res://scenes/items/world_item.tscn")
const EQUIPMENT_DEFINITION: ItemDefinition = preload("res://data/items/emberwood_bow.tres")
const APPROACH_DISTANCE := 94.0

@export var player_path: NodePath = NodePath("../Hub/Player")

var player: PlayerActor
var target: EnemyActor
var _attack_cooldown := 0.0

func _ready() -> void:
	player = get_node_or_null(player_path) as PlayerActor
	if player != null:
		player.attack_requested.connect(_on_attack_requested)
		player.movement_command_issued.connect(_on_movement_command_issued)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(target) or target.is_defeated or player == null:
		target = null
		return
	_attack_cooldown = maxf(0.0, _attack_cooldown - delta)
	var offset := target.global_position - player.global_position
	if offset.length() > player.definition.basic_attack_range:
		if not player.is_moving():
			var approach := target.global_position - offset.normalized() * APPROACH_DISTANCE
			player.command_move_to(approach)
		return
	player.stop_movement()
	if _attack_cooldown <= 0.0:
		_fire_projectile(target)
		_attack_cooldown = player.definition.basic_attack_interval

func _on_attack_requested(enemy: EnemyActor) -> void:
	if enemy == null or enemy.is_defeated:
		return
	if not enemy.defeated.is_connected(_on_enemy_defeated):
		enemy.defeated.connect(_on_enemy_defeated, CONNECT_ONE_SHOT)
	target = enemy
	_attack_cooldown = 0.0

func _on_movement_command_issued() -> void:
	target = null

func _fire_projectile(enemy: EnemyActor) -> void:
	var projectile := PROJECTILE_SCENE.instantiate() as BasicProjectile
	if projectile == null:
		return
	var direction := (enemy.global_position - player.global_position).normalized()
	projectile.direction = direction
	projectile.speed = player.definition.projectile_speed
	projectile.damage = player.definition.basic_attack_damage
	projectile.target = enemy
	projectile.global_position = player.global_position + direction * 15.0
	get_parent().add_child(projectile)

func _on_enemy_defeated(enemy: EnemyActor) -> void:
	if target == enemy:
		target = null
	var item := EQUIPMENT_SCENE.instantiate() as WorldItem
	if item == null:
		return
	item.definition = EQUIPMENT_DEFINITION
	# A southward offset can move drops beyond the triangular ground edge.
	item.global_position = enemy.global_position + Vector2(0, -20)
	get_parent().call_deferred("add_child", item)
