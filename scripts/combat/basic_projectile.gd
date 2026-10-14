extends Area2D
class_name BasicProjectile

var direction: Vector2 = Vector2.RIGHT
var speed: float = 420.0
var damage: int = 1
var target: EnemyActor
var _remaining_lifetime := 2.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	_remaining_lifetime -= delta
	if _remaining_lifetime <= 0.0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == target and is_instance_valid(target) and not target.is_defeated:
		target.take_damage(damage)
	queue_free()
