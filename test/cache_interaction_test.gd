extends GdUnitTestSuite

var _main: Node
var _world: Node
var _player: PlayerActor
var _cache: MapCache
var _progression: PlayerProgression
var _navigation: NavigationGrid
var _manager: Node

func before_test() -> void:
	_manager = get_node("/root/SaveManager")
	_manager.set("storage_directory", "user://gdunit_cache_tests_%d" % Time.get_ticks_usec())
	_manager.call("clear_pending_game_data")
	_main = WorldTestFixture.create_main()
	add_child(_main)
	_main.call("_start_new_game")
	_world = _main.get_node("World")
	_player = _world.get_node("Hub/Player") as PlayerActor
	_cache = _world.get_node("Exploration/TestCache") as MapCache
	_progression = _world.get_node("PlayerProgression") as PlayerProgression
	_navigation = _world.get_node("NavigationGrid") as NavigationGrid
	await get_tree().physics_frame
	await get_tree().physics_frame

func after_test() -> void:
	_main.free()
	var directory_path := ProjectSettings.globalize_path(_manager.get("storage_directory"))
	var directory := DirAccess.open(directory_path)
	if directory != null:
		for file_name: String in directory.get_files():
			DirAccess.remove_absolute(directory_path.path_join(file_name))
		DirAccess.remove_absolute(directory_path)
	_manager.call("clear_pending_game_data")
	_manager.set("storage_directory", "user://saves")

func test_click_approaches_and_opens_cache_without_attacking() -> void:
	var combat := _world.get_node("CombatController") as CombatController
	var enemy := _world.get_node("Exploration/TrainingSentinel") as EnemyActor
	_player.attack_requested.emit(enemy)
	assert_object(combat.target).is_same(enemy)
	_player.call("_issue_pointer_command", _cache.global_position)
	assert_bool(_cache.opened).is_false()
	assert_object(combat.target).is_null()
	assert_bool(_player.is_moving()).is_true()
	assert_int(_piles().size()).is_equal(0)
	await _wait_for_open()
	assert_bool(_cache.opened).is_true()
	assert_int(_piles().size()).is_equal(1)
	assert_float(_player.global_position.distance_to(_cache.global_position)).is_less_equal(_cache.interaction_range)
	assert_int(enemy.current_health).is_equal(5)
	assert_int(_progression.gold).is_equal(100)

func test_gold_requires_click_and_approach_and_is_transferred_once() -> void:
	_player.global_position = _cache.global_position
	_player.call("_issue_pointer_command", _cache.global_position)
	await _wait_for_open()
	var pile := _piles()[0] as GoldPickup
	var reward := pile.amount
	_player.global_position = pile.global_position
	await get_tree().physics_frame
	assert_int(_progression.gold).is_equal(100)
	assert_bool(pile.collected).is_false()
	_player.global_position = Vector2(-155, 20)
	_player.call("_issue_pointer_command", pile.global_position)
	assert_int(_progression.gold).is_equal(100)
	for _frame in range(240):
		await get_tree().physics_frame
		if _piles().is_empty():
			break
	assert_int(_piles().size()).is_equal(0)
	assert_int(_progression.gold).is_equal(100 + reward)
	var gold_label := _world.get_node("Inventory/Panel/Contents/Gold") as Label
	assert_str(gold_label.text).is_equal("Золото: %d" % (100 + reward))
	await get_tree().physics_frame
	assert_int(_progression.gold).is_equal(100 + reward)

func test_cache_reward_bounds_and_one_pile_per_session() -> void:
	for _run in range(64):
		_cache.reset_cache()
		assert_bool(_cache.interact(_player, _progression, _navigation)).is_true()
		assert_bool(_cache.interact(_player, _progression, _navigation)).is_false()
		assert_int(_piles().size()).is_equal(1)
		var pile := _piles()[0] as GoldPickup
		assert_int(pile.amount).is_greater_equal(1)
		assert_int(pile.amount).is_less_equal(20)
		assert_bool(_navigation.is_point_on_ground(pile.global_position)).is_true()
		assert_bool(_navigation.is_point_blocked(pile.global_position, _player)).is_false()
		assert_bool(_navigation.find_path(_player.global_position, pile.global_position, false, _player).is_empty()).is_false()
		pile.free()

func test_reward_near_boundary_falls_back_to_valid_ground() -> void:
	_cache.global_position = Vector2(390, 0)
	assert_bool(_cache.interact(_player, _progression, _navigation)).is_true()
	var pile := _piles()[0] as GoldPickup
	assert_bool(_navigation.is_point_on_ground(pile.global_position)).is_true()
	assert_bool(_navigation.is_point_blocked(pile.global_position, _player)).is_false()
	assert_bool(_navigation.find_path(_player.global_position, pile.global_position, false, _player).is_empty()).is_false()
	assert_float(pile.global_position.x).is_less(420.0)

func test_unreachable_cache_and_gold_do_not_open_or_collect_remotely() -> void:
	_cache.global_position = Vector2(600, 0)
	var initial_position := _player.global_position
	_player.call("_issue_pointer_command", _cache.global_position)
	await get_tree().physics_frame
	assert_bool(_cache.opened).is_false()
	assert_bool(_player.is_moving()).is_false()
	assert_bool(_player.global_position == initial_position).is_true()
	var pile := (load("res://scenes/items/gold_pickup.tscn") as PackedScene).instantiate() as GoldPickup
	_world.add_child(pile)
	pile.global_position = Vector2(600, 100)
	_player.call("_issue_pointer_command", pile.global_position)
	await get_tree().physics_frame
	assert_bool(pile.collected).is_false()
	assert_int(_progression.gold).is_equal(100)
	assert_bool(_player.global_position == initial_position).is_true()

func test_nearby_cache_behind_wall_requires_path_within_interaction_range() -> void:
	_player.global_position = Vector2(140, 0)
	_cache.global_position = Vector2(220, 0)
	_cache.interaction_range = 96.0
	assert_float(_player.global_position.distance_to(_cache.global_position)).is_less(_cache.interaction_range)
	_player.call("_issue_pointer_command", _cache.global_position)
	var controller := _world.get_node("InteractionController") as InteractionController
	controller.call("_physics_process", 0.0)
	assert_bool(_cache.opened).is_false()
	assert_bool(_player.is_moving()).is_true()

func test_ground_and_enemy_commands_cancel_pending_interaction() -> void:
	var controller := _world.get_node("InteractionController") as InteractionController
	_player.call("_issue_pointer_command", _cache.global_position)
	assert_object(controller.target).is_same(_cache)
	_player.call("_issue_pointer_command", Vector2(-100, 0))
	assert_object(controller.target).is_null()
	_player.call("_issue_pointer_command", _cache.global_position)
	var enemy := _world.get_node("Exploration/TrainingSentinel") as EnemyActor
	_player.call("_issue_pointer_command", enemy.global_position)
	assert_object(controller.target).is_null()
	assert_bool(_cache.opened).is_false()

func test_loading_preserves_saved_gold_resets_cache_and_discards_uncollected_pile() -> void:
	assert_bool(_cache.interact(_player, _progression, _navigation)).is_true()
	var pile := _piles()[0] as GoldPickup
	var saved_gold := 100 + pile.amount
	assert_bool(pile.interact(_player, _progression, _navigation)).is_true()
	assert_bool(pile.interact(_player, _progression, _navigation)).is_false()
	assert_int(_progression.gold).is_equal(saved_gold)
	await get_tree().physics_frame
	assert_bool(_world.call("save_manual", "manual_1")).is_true()
	_main.call("_load_slot", "manual_1")
	assert_bool(_cache.opened).is_false()
	assert_int(_progression.gold).is_equal(saved_gold)
	assert_bool(_cache.interact(_player, _progression, _navigation)).is_true()
	assert_int(_piles().size()).is_equal(1)
	_progression.gold = 1
	_main.call("_load_slot", "manual_1")
	await get_tree().physics_frame
	assert_bool(_cache.opened).is_false()
	assert_int(_piles().size()).is_equal(0)
	assert_int(_progression.gold).is_equal(saved_gold)
	var gold_label := _world.get_node("Inventory/Panel/Contents/Gold") as Label
	assert_str(gold_label.text).is_equal("Золото: %d" % saved_gold)
	assert_bool(_cache.interact(_player, _progression, _navigation)).is_true()
	assert_int(_piles().size()).is_equal(1)

func test_player_is_drawn_in_front_of_cache_when_below_and_behind_when_above() -> void:
	# Check rendered overlap, including sorting across the two area parents.
	var viewport := SubViewport.new()
	viewport.size = Vector2i(1280, 720)
	viewport.world_2d = get_viewport().world_2d
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	_world.add_child(viewport)
	viewport.canvas_transform = get_viewport().canvas_transform
	_player.stop_movement()
	_player.global_position = _cache.global_position + Vector2(0, 5)
	RenderingServer.force_draw(false)
	var sample := viewport.canvas_transform * (_cache.global_position + Vector2(0, -8))
	var image := viewport.get_texture().get_image()
	var pixel := image.get_pixelv(Vector2i(sample))
	var player_color := (_player.get_node("PlaceholderSprite") as Polygon2D).color
	image.save_png("res://reports/cache-player-front.png")
	assert_float(pixel.r).is_equal_approx(player_color.r, 0.01)
	assert_float(pixel.g).is_equal_approx(player_color.g, 0.01)
	assert_float(pixel.b).is_equal_approx(player_color.b, 0.01)
	_player.global_position = _cache.global_position - Vector2(0, 5)
	RenderingServer.force_draw(false)
	image = viewport.get_texture().get_image()
	pixel = image.get_pixelv(Vector2i(sample))
	var cache_color := (_cache.get_node("Visual") as Polygon2D).color
	image.save_png("res://reports/cache-player-behind.png")
	assert_float(pixel.r).is_equal_approx(cache_color.r, 0.01)
	assert_float(pixel.g).is_equal_approx(cache_color.g, 0.01)
	assert_float(pixel.b).is_equal_approx(cache_color.b, 0.01)
	for boundary_name: String in ["NorthBoundary", "SouthBoundary"]:
		var boundary := _world.get_node(boundary_name) as Node2D
		var boundary_sample := viewport.canvas_transform * boundary.global_position
		var boundary_color := (boundary.get_node("BoundaryVisual") as Polygon2D).color
		pixel = image.get_pixelv(Vector2i(boundary_sample))
		assert_float(pixel.r).is_equal_approx(boundary_color.r, 0.01)
		assert_float(pixel.g).is_equal_approx(boundary_color.g, 0.01)
		assert_float(pixel.b).is_equal_approx(boundary_color.b, 0.01)

func test_player_walks_through_closed_and_open_cache_without_collision() -> void:
	assert_bool(_cache.find_children("*", "CollisionObject2D", true, false).is_empty()).is_true()
	for opened: bool in [false, true]:
		_cache.opened = opened
		_cache.call("_refresh_visual")
		_player.global_position = _cache.global_position - Vector2(40, 0)
		var destination := _cache.global_position + Vector2(40, 0)
		assert_bool(_navigation.is_point_blocked(_cache.global_position, _player)).is_false()
		_player.call("_issue_pointer_command", destination)
		var closest_distance := INF
		for _frame in range(120):
			await get_tree().physics_frame
			closest_distance = minf(closest_distance, _player.global_position.distance_to(_cache.global_position))
			if not _player.is_moving():
				break
		assert_float(closest_distance).is_less(5.0)
		assert_float(_player.global_position.distance_to(destination)).is_less_equal(4.0)
		assert_bool(_cache.opened == opened).is_true()
		assert_int(_piles().size()).is_equal(0)

func _piles() -> Array[Node]:
	var piles: Array[Node] = []
	for node: Node in get_tree().get_nodes_in_group("gold_pickups"):
		if _world.is_ancestor_of(node) and not node.is_queued_for_deletion():
			piles.append(node)
	return piles

func _wait_for_open() -> void:
	for _frame in range(240):
		await get_tree().physics_frame
		if _cache.opened:
			return
