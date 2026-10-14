extends CharacterBody2D
class_name EnemyActor

signal damaged(remaining_health: int)
signal defeated(enemy: EnemyActor)

@export var definition: EnemyDefinition
@export var click_radius: float = 18.0

@onready var _sprite: Polygon2D = get_node_or_null("PlaceholderSprite") as Polygon2D
@onready var _collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D

var current_health: int = 0
var is_defeated: bool = false

func _ready() -> void:
	add_to_group("enemies")
	add_to_group("movement_obstacles")
	current_health = definition.max_health if definition != null else 1

func take_damage(amount: int) -> void:
	if is_defeated or amount <= 0:
		return
	current_health = maxi(0, current_health - amount)
	damaged.emit(current_health)
	if current_health == 0:
		is_defeated = true
		remove_from_group("enemies")
		remove_from_group("movement_obstacles")
		if _collision_shape != null:
			_collision_shape.set_deferred("disabled", true)
		if _sprite != null:
			var defeat_tween := create_tween()
			defeat_tween.tween_property(_sprite, "modulate", Color(0.25, 0.25, 0.25, 0.45), 0.25)
		defeated.emit(self)
	elif _sprite != null:
		_sprite.modulate = Color(1.0, 0.65, 0.45, 1.0)
		var hit_tween := create_tween()
		hit_tween.tween_property(_sprite, "modulate", Color.WHITE, 0.18)
