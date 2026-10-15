extends CharacterBody2D
class_name PlayerActor

signal attack_requested(target: EnemyActor)
signal movement_command_issued
signal health_changed(current_health: int, maximum_health: int)

@export var definition: PlayerDefinition
@export var move_speed: float = 180.0

var _path := PackedVector2Array()
var _path_index := 0
var _left_button_held := false
var _last_hold_goal := Vector2(INF, INF)
var _navigation: NavigationGrid
var max_health: int = 100
var current_health: int = 100

func _ready() -> void:
	add_to_group("player_actor")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	max_health = maxi(1, definition.max_health) if definition != null else 100
	current_health = clampi(definition.starting_health, 0, max_health) if definition != null else max_health
	var world := get_parent().get_parent()
	_navigation = world.get_node_or_null("NavigationGrid") as NavigationGrid
	if _navigation == null:
		for candidate: Node in get_tree().get_nodes_in_group("world_navigation"):
			if is_instance_valid(candidate):
				_navigation = candidate as NavigationGrid
				break
	health_changed.emit(current_health, max_health)

func heal(amount: int) -> int:
	if amount <= 0:
		return 0
	var previous_health := current_health
	current_health = mini(max_health, current_health + amount)
	if current_health != previous_health:
		health_changed.emit(current_health, max_health)
	return current_health - previous_health

func take_damage(amount: int) -> int:
	if amount <= 0:
		return 0
	var previous_health := current_health
	current_health = maxi(0, current_health - amount)
	if current_health != previous_health:
		health_changed.emit(current_health, max_health)
	return previous_health - current_health

func restore_full_health() -> void:
	if current_health == max_health:
		return
	current_health = max_health
	health_changed.emit(current_health, max_health)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_issue_pointer_command(get_global_mouse_position())
			_left_button_held = true
			_last_hold_goal = get_global_mouse_position()
		else:
			_left_button_held = false
	elif event is InputEventMouseMotion and _left_button_held:
		_update_held_goal(get_global_mouse_position())

func _physics_process(_delta: float) -> void:
	if _left_button_held:
		_update_held_goal(get_global_mouse_position())
	if _path_index >= _path.size():
		velocity = Vector2.ZERO
		return
	var next_point := _path[_path_index]
	var offset := next_point - global_position
	if offset.length() <= 4.0:
		_path_index += 1
		if _path_index >= _path.size():
			velocity = Vector2.ZERO
			return
		next_point = _path[_path_index]
		offset = next_point - global_position
	velocity = offset.normalized() * move_speed
	move_and_slide()
	if get_slide_collision_count() > 0:
		var remaining := next_point - global_position
		if remaining.length() > 8.0:
			_request_move_to(next_point, false)

func command_move_to(destination: Vector2) -> void:
	_request_move_to(destination, true)

func stop_movement() -> void:
	_path.clear()
	_path_index = 0
	velocity = Vector2.ZERO

func is_moving() -> bool:
	return _path_index < _path.size()

func _update_held_goal(goal: Vector2) -> void:
	if _last_hold_goal.distance_squared_to(goal) < 25.0:
		return
	_last_hold_goal = goal
	_issue_pointer_command(goal)

func _issue_pointer_command(point: Vector2) -> void:
	var enemy := _enemy_at(point)
	if enemy != null:
		stop_movement()
		attack_requested.emit(enemy)
		return
	movement_command_issued.emit()
	var off_ground := _navigation == null or not _navigation.is_point_on_ground(point)
	var blocked := _navigation != null and _navigation.is_point_blocked(point, self)
	_request_move_to(point, off_ground or blocked)

func _request_move_to(destination: Vector2, resolve_boundary: bool) -> void:
	if _navigation == null:
		_path.clear()
		_path_index = 0
		velocity = Vector2.ZERO
		return
	_path = _navigation.find_path(global_position, destination, resolve_boundary, self)
	_path_index = 1 if _path.size() > 1 else _path.size()
	if _path.is_empty():
		_path_index = 0
		velocity = Vector2.ZERO

func _enemy_at(point: Vector2) -> EnemyActor:
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as EnemyActor
		if enemy != null and enemy.global_position.distance_to(point) <= enemy.click_radius:
			return enemy
	return null
