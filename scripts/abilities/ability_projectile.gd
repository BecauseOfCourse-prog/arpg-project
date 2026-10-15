extends Area2D
class_name AbilityProjectile

var direction: Vector2 = Vector2.RIGHT
var speed: float = 420.0
var damage: int = 2
var _remaining_lifetime := 2.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_remaining_lifetime -= delta
	if _remaining_lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	var enemy := body as EnemyActor
	if enemy != null and not enemy.is_defeated:
		enemy.take_damage(damage)
	queue_free()
