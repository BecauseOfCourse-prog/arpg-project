extends CharacterBody2D
class_name PlayerActor

signal attack_requested(target: EnemyActor)
signal movement_command_issued
signal interaction_requested(target: WorldInteractable)
signal health_changed(current_health: int, maximum_health: int)

@export var definition: PlayerDefinition
@export var move_speed: float = 180.0

const HOLD_DELAY := 0.20
const HOLD_DRAG_DISTANCE := 8.0

var _path := PackedVector2Array()
var _path_index := 0
var _left_button_held := false
var _last_hold_goal := Vector2(INF, INF)
var _pointer_screen_position := Vector2.ZERO
var _press_screen_position := Vector2.ZERO
var _hold_elapsed := 0.0
var _holding_for_movement := false
var _pending_click_target: Node2D
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
		_pointer_screen_position = event.position
		if event.pressed:
			cancel_pointer_input()
			_left_button_held = true
			_press_screen_position = event.position
			var point := _screen_to_world(event.position)
			_pending_click_target = _interactable_at(point)
			if _pending_click_target == null:
				_pending_click_target = _enemy_at(point)
			if _pending_click_target != null:
				movement_command_issued.emit()
				stop_movement()
			else:
				_begin_movement_hold(point)
		else:
			if _left_button_held and not _holding_for_movement and _hold_elapsed < HOLD_DELAY and event.position.distance_to(_press_screen_position) < HOLD_DRAG_DISTANCE:
				if is_instance_valid(_pending_click_target) and not _pending_click_target.is_queued_for_deletion():
					_issue_pointer_command(_pending_click_target.global_position)
			cancel_pointer_input()
	elif event is InputEventMouseMotion and _left_button_held:
		_pointer_screen_position = event.position
		if not _holding_for_movement and event.position.distance_to(_press_screen_position) >= HOLD_DRAG_DISTANCE:
			_begin_movement_hold(_screen_to_world(event.position))
		if _holding_for_movement:
			_update_held_goal(_screen_to_world(event.position))

func _physics_process(delta: float) -> void:
	if _left_button_held:
		_hold_elapsed += delta
		if not _holding_for_movement and _hold_elapsed >= HOLD_DELAY:
			_begin_movement_hold(_screen_to_world(_pointer_screen_position))
		if _holding_for_movement:
			_update_held_goal(_screen_to_world(_pointer_screen_position))
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

func cancel_pointer_input() -> void:
	_left_button_held = false
	_holding_for_movement = false
	_hold_elapsed = 0.0
	_pending_click_target = null
	_last_hold_goal = Vector2(INF, INF)

func _screen_to_world(point: Vector2) -> Vector2:
	return to_global(get_global_transform_with_canvas().affine_inverse() * point)

func _begin_movement_hold(point: Vector2) -> void:
	_pending_click_target = null
	_holding_for_movement = true
	_last_hold_goal = point
	_issue_movement_command(point)

func _update_held_goal(goal: Vector2) -> void:
	if _last_hold_goal.distance_squared_to(goal) < 25.0:
		return
	_last_hold_goal = goal
	_issue_movement_command(goal)

func _issue_pointer_command(point: Vector2) -> void:
	var interactable := _interactable_at(point)
	if interactable != null:
		movement_command_issued.emit()
		interaction_requested.emit(interactable)
		return
	var enemy := _enemy_at(point)
	if enemy != null:
		stop_movement()
		attack_requested.emit(enemy)
		return
	_issue_movement_command(point)

func _issue_movement_command(point: Vector2) -> void:
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

func _interactable_at(point: Vector2) -> WorldInteractable:
	# Gold takes priority if a reward shares the opened cache's footprint.
	var closest: WorldInteractable
	var closest_distance := INF
	for node: Node in get_tree().get_nodes_in_group("world_interactables"):
		var interactable := node as WorldInteractable
		if interactable == null or interactable.is_queued_for_deletion():
			continue
		var distance := interactable.global_position.distance_to(point)
		if distance > interactable.click_radius:
			continue
		var gold_priority := interactable is GoldPickup and not closest is GoldPickup
		var same_priority := (interactable is GoldPickup) == (closest is GoldPickup)
		if closest == null or gold_priority or (same_priority and distance < closest_distance):
			closest = interactable
			closest_distance = distance
	return closest
