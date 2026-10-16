extends GdUnitTestSuite

var _main: Node
var _world: Node2D
var _player: PlayerActor
var _enemy: EnemyActor
var _cache: MapCache
var _vendor: VendorInteractable
var _gold: GoldPickup
var _combat: CombatController
var _interactions: InteractionController
var _requests: Array[int] = [0, 0]

func before_test() -> void:
	_main = (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	add_child(_main)
	_main.call("_start_new_game")
	_world = _main.get_node("World") as Node2D
	_world.call("regenerate_exploration", 23)
	_player = _world.get_node("Hub/Player") as PlayerActor
	_enemy = _world.find_children("*", "EnemyActor", true, false)[0] as EnemyActor
	_cache = _world.find_children("*", "MapCache", true, false)[0] as MapCache
	_vendor = _world.get_node("Hub/Vendor") as VendorInteractable
	_combat = _world.get_node("CombatController") as CombatController
	_interactions = _world.get_node("InteractionController") as InteractionController
	_gold = (load("res://scenes/items/gold_pickup.tscn") as PackedScene).instantiate() as GoldPickup
	_gold.position = _cache.global_position + Vector2(32, 0)
	_world.add_child(_gold)
	_requests = [0, 0]
	_player.attack_requested.connect(func(_target: EnemyActor) -> void: _requests[0] += 1)
	_player.interaction_requested.connect(func(_target: WorldInteractable) -> void: _requests[1] += 1)
	await get_tree().physics_frame
	await get_tree().physics_frame

func after_test() -> void:
	_main.free()

func test_short_enemy_click_fires_once_and_survives_following_camera() -> void:
	var screen := _screen_point(_enemy.global_position)
	_button(screen, true)
	assert_int(_requests[0]).is_equal(0)
	_button(screen, false)
	assert_int(_requests[0]).is_equal(1)
	assert_object(_combat.target).is_same(_enemy)
	var initial_position := _player.global_position
	for _frame in range(18):
		await get_tree().physics_frame
	assert_float(_player.global_position.distance_to(initial_position)).is_greater(18.0)
	assert_object(_combat.target).is_same(_enemy)
	assert_int(_requests[0]).is_equal(1)
	assert_int(_requests[1]).is_equal(0)
	assert_bool(_player.get("_left_button_held")).is_false()

func test_short_cache_gold_and_vendor_clicks_request_interaction_once_on_release() -> void:
	for target: WorldInteractable in [_cache, _gold, _vendor]:
		_move_player_near(target)
		var before := _requests[1]
		var screen := _screen_point(target.global_position)
		_button(screen, true)
		assert_int(_requests[1]).is_equal(before)
		_button(screen, false)
		assert_int(_requests[1]).is_equal(before + 1)
		assert_object(_interactions.target).is_same(target)
	assert_int(_requests[0]).is_equal(0)

func test_holding_directly_on_objects_only_moves_without_attack_or_interaction() -> void:
	for target: Node2D in [_enemy, _cache, _gold, _vendor]:
		_move_player_near(target)
		var screen := _screen_point(target.global_position)
		_button(screen, true)
		assert_bool(_player.is_moving()).is_false()
		_player.call("_physics_process", PlayerActor.HOLD_DELAY + 0.01)
		assert_bool(_player.is_moving()).is_true()
		assert_int(_requests[0]).is_equal(0)
		assert_int(_requests[1]).is_equal(0)
		_button(screen, false)
		assert_int(_requests[0]).is_equal(0)
		assert_int(_requests[1]).is_equal(0)
		assert_object(_combat.target).is_null()
		assert_object(_interactions.target).is_null()
	assert_bool(_cache.opened).is_false()
	assert_bool(_gold.collected).is_false()
	assert_bool((_world.get_node("VendorWindow") as VendorWindow).visible).is_false()

func test_holding_from_ground_and_hovering_objects_only_updates_movement() -> void:
	for target: Node2D in [_enemy, _cache, _gold, _vendor]:
		_move_player_near(target)
		_button(_screen_point(_player.global_position + Vector2(0, 40)), true)
		var screen := _screen_point(target.global_position)
		_motion(screen)
		assert_bool(_player.is_moving()).is_true()
		assert_int(_requests[0]).is_equal(0)
		assert_int(_requests[1]).is_equal(0)
		_button(screen, false)
		assert_int(_requests[0]).is_equal(0)
		assert_int(_requests[1]).is_equal(0)
	assert_bool(_cache.opened).is_false()
	assert_bool(_gold.collected).is_false()

func test_dragging_an_object_press_becomes_movement_without_a_click() -> void:
	_move_player_near(_cache)
	var screen := _screen_point(_cache.global_position)
	_button(screen, true)
	screen += Vector2(PlayerActor.HOLD_DRAG_DISTANCE + 2, 0)
	_motion(screen)
	assert_bool(_player.is_moving()).is_true()
	_button(screen, false)
	assert_int(_requests[0]).is_equal(0)
	assert_int(_requests[1]).is_equal(0)
	assert_bool(_cache.opened).is_false()

func test_ground_hold_follows_viewport_cursor_with_moving_camera() -> void:
	var initial := _player.global_position
	var screen := _screen_point(initial + Vector2(80, 0))
	_button(screen, true)
	for _frame in range(18):
		await get_tree().physics_frame
	assert_float(_player.global_position.distance_to(initial)).is_greater(30.0)
	var expected: Vector2 = _player.call("_screen_to_world", screen)
	var current: Vector2 = _player.get("_last_hold_goal")
	assert_float(current.distance_to(expected)).is_less_equal(6.0)
	assert_int(_requests[0]).is_equal(0)
	assert_int(_requests[1]).is_equal(0)
	_button(screen, false)
	assert_bool(_player.get("_left_button_held")).is_false()

func test_regeneration_cancels_an_incomplete_object_click() -> void:
	_move_player_near(_cache)
	var screen := _screen_point(_cache.global_position)
	_button(screen, true)
	_world.call("regenerate_exploration", 24)
	_button(screen, false)
	assert_bool(_player.get("_left_button_held")).is_false()
	assert_int(_requests[0]).is_equal(0)
	assert_int(_requests[1]).is_equal(0)

func _move_player_near(target: Node2D) -> void:
	_player.cancel_pointer_input()
	_player.stop_movement()
	_player.global_position = target.global_position - Vector2(100, 0)
	_world.call("_update_camera")

func _screen_point(point: Vector2) -> Vector2:
	return _player.get_global_transform_with_canvas() * _player.to_local(point)

func _button(screen: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = screen
	event.pressed = pressed
	event.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	_player.call("_unhandled_input", event)

func _motion(screen: Vector2) -> void:
	var event := InputEventMouseMotion.new()
	event.position = screen
	event.button_mask = MOUSE_BUTTON_MASK_LEFT
	_player.call("_unhandled_input", event)
