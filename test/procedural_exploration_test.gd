extends GdUnitTestSuite

var _main: Node
var _world: Node2D
var _player: PlayerActor
var _navigation: NavigationGrid
var _manager: Node
var _hub_polygon: PackedVector2Array

func before_test() -> void:
	_manager = get_node("/root/SaveManager")
	_manager.set("storage_directory", "user://gdunit_generation_tests_%d" % Time.get_ticks_usec())
	_manager.call("clear_pending_game_data")
	_main = (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	_world = _main.get_node("World") as Node2D
	_hub_polygon = (_world.get_node("Hub/Ground") as Polygon2D).polygon.duplicate()
	add_child(_main)
	_main.call("_start_new_game")
	_player = _world.get_node("Hub/Player") as PlayerActor
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

func test_generation_varies_sizes_passage_and_content_within_valid_bounds() -> void:
	var generator := ExplorationGenerator.new()
	var sizes: Dictionary = {}
	var passages: Dictionary = {}
	var enemy_positions: Dictionary = {}
	var cache_positions: Dictionary = {}
	var wall_positions: Dictionary = {}
	for seed_value in range(64):
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		var layout := generator.generate(rng)
		assert_int(layout["zones"].size()).is_equal(2)
		for zone: Rect2 in layout["zones"]:
			assert_bool(ExplorationGenerator.SIZES.has(int(zone.size.x))).is_true()
			assert_bool(ExplorationGenerator.SIZES.has(int(zone.size.y))).is_true()
			sizes[zone.size] = true
		var first: Rect2 = layout["zones"][0]
		var second: Rect2 = layout["zones"][1]
		var passage: Vector2 = layout["passage"]
		assert_float(first.position.x).is_zero()
		assert_float(first.get_center().y).is_zero()
		assert_float(passage.x).is_equal(first.end.x)
		assert_float(second.position.x).is_equal(passage.x)
		assert_float(second.get_center().y).is_equal(passage.y)
		assert_float(passage.y - first.position.y).is_greater_equal(64.0)
		assert_float(first.end.y - passage.y).is_greater_equal(64.0)
		var wall := Rect2(Vector2(layout["wall"]) - ExplorationGenerator.WALL_SIZE / 2, ExplorationGenerator.WALL_SIZE)
		var wall_zone: Rect2 = layout["zones"][layout["wall_zone"]]
		assert_bool(wall_zone.encloses(wall.grow(10))).is_true()
		assert_bool(wall.grow(26).has_point(layout["enemy"])).is_false()
		assert_bool(wall.grow(22).has_point(layout["cache"])).is_false()
		var enemy_zone: Rect2 = layout["zones"][layout["enemy_zone"]]
		var cache_zone: Rect2 = layout["zones"][layout["cache_zone"]]
		assert_bool(enemy_zone.grow(-26).has_point(layout["enemy"])).is_true()
		assert_bool(cache_zone.grow(-22).has_point(layout["cache"])).is_true()
		assert_float(Vector2(layout["enemy"]).distance_to(layout["cache"])).is_greater_equal(72.0)
		passages[passage.y] = true
		enemy_positions[layout["enemy"]] = true
		cache_positions[layout["cache"]] = true
		wall_positions[layout["wall"]] = true
	assert_int(sizes.size()).is_greater(1)
	assert_int(passages.size()).is_greater(1)
	assert_int(enemy_positions.size()).is_greater(1)
	assert_int(cache_positions.size()).is_greater(1)
	assert_int(wall_positions.size()).is_greater(1)

func test_generated_runtime_navigation_is_connected_and_uses_only_passages() -> void:
	for seed_value in range(32):
		_world.call("regenerate_exploration", seed_value)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var layout: Dictionary = _world.get("exploration_layout")
		var second: Rect2 = layout["zones"][1]
		var passage: Vector2 = layout["passage"]
		assert_bool(_navigation.is_fully_connected(_player.global_position, _player)).is_true()
		assert_bool((_world.get_node("Hub/Ground") as Polygon2D).polygon == _hub_polygon).is_true()
		assert_vector((_world.get_node("Hub/Vendor") as Node2D).position).is_equal(Vector2(-280, 30))
		assert_vector((_world.get_node("NorthBoundary") as Node2D).position).is_equal(Vector2(0, -132))
		assert_vector((_world.get_node("SouthBoundary") as Node2D).position).is_equal(Vector2(0, 132))
		assert_int(_world.find_children("*", "WorldArea", true, false).size()).is_equal(3)
		assert_int(_world.find_children("*", "EnemyActor", true, false).size()).is_equal(1)
		assert_int(_world.find_children("*", "MapCache", true, false).size()).is_equal(1)
		assert_bool(_navigation.is_point_blocked(Vector2.ZERO, _player)).is_false()
		assert_bool(_navigation.is_point_blocked(Vector2(0, -100), _player)).is_true()
		assert_bool(_navigation.is_point_blocked(passage, _player)).is_false()
		var first: Rect2 = layout["zones"][0]
		var blocked_y := passage.y + 80.0 if first.end.y - passage.y >= 100 else passage.y - 80.0
		assert_bool(_navigation.is_point_blocked(Vector2(passage.x, blocked_y), _player)).is_true()
		var path := _navigation.find_path(_player.global_position, second.get_center(), true, _player)
		assert_bool(path.is_empty()).is_false()
		assert_bool(_crossings_use_passage(path, 0.0, 0.0)).is_true()
		assert_bool(_crossings_use_passage(path, passage.x, passage.y)).is_true()
		var cache := _world.find_children("*", "MapCache", true, false)[0] as MapCache
		assert_bool(_navigation.find_path(_player.global_position, cache.global_position, false, _player).is_empty()).is_false()
		var enemy := _world.find_children("*", "EnemyActor", true, false)[0] as EnemyActor
		assert_bool(_navigation.find_path(_player.global_position, enemy.global_position, true, _player).is_empty()).is_false()

func test_player_traverses_second_zone_with_stable_layout_and_following_camera() -> void:
	_world.call("regenerate_exploration", 23)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var layout: Dictionary = _world.get("exploration_layout").duplicate(true)
	var revision := int(_world.get("generation_revision"))
	var second: Rect2 = layout["zones"][1]
	var path := _navigation.find_path(_player.global_position, second.get_center(), true, _player)
	assert_bool(path.is_empty()).is_false()
	_player.command_move_to(path[path.size() - 1])
	for _frame in range(720):
		await get_tree().physics_frame
		if not _player.is_moving():
			break
	assert_bool(second.grow(-20).has_point(_player.global_position)).is_true()
	assert_int(int(_world.get("generation_revision"))).is_equal(revision)
	assert_bool(_world.get("exploration_layout") == layout).is_true()
	var camera := _world.get_node("Camera2D") as Camera2D
	assert_float(camera.global_position.distance_to(_player.global_position)).is_less_equal(4.0)
	_player.command_move_to(ExplorationGenerator.HUB_SPAWN)
	for _frame in range(720):
		await get_tree().physics_frame
		if not _player.is_moving():
			break
	assert_float(_player.global_position.distance_to(ExplorationGenerator.HUB_SPAWN)).is_less_equal(4.0)
	assert_int(int(_world.get("generation_revision"))).is_equal(revision)
	assert_bool(_world.get("exploration_layout") == layout).is_true()

func test_load_regenerates_content_discards_rewards_and_restores_owned_state_in_hub() -> void:
	var progression := _world.get_node("PlayerProgression") as PlayerProgression
	var inventory := _world.get_node("Inventory") as InventoryController
	progression.gold = 431
	assert_bool(inventory.add_item(load("res://data/items/health_potion.tres") as ItemDefinition, 3)).is_true()
	assert_bool(_world.call("save_manual", "manual_1")).is_true()
	var slot: Dictionary = _manager.call("get_slot_info", "manual_1")
	var payload: Dictionary = slot["payload"]
	assert_bool(payload.has("exploration_layout")).is_false()
	assert_bool(payload.has("seed")).is_false()
	assert_bool(payload.has("position")).is_false()
	var cache := _world.find_children("*", "MapCache", true, false)[0] as MapCache
	var old_cache_id := cache.get_instance_id()
	_player.global_position = cache.global_position
	assert_bool(cache.interact(_player, progression, _navigation)).is_true()
	var item := (load("res://scenes/items/world_item.tscn") as PackedScene).instantiate()
	_world.add_child(item)
	var projectile := (load("res://scenes/combat/basic_projectile.tscn") as PackedScene).instantiate()
	_world.add_child(projectile)
	var enemy := _world.find_children("*", "EnemyActor", true, false)[0] as EnemyActor
	# A reward queued before load must not appear in the replacement world.
	(_world.get_node("CombatController") as CombatController).call("_on_enemy_defeated", enemy)
	progression.gold = 0
	inventory.remove_item_at(0)
	_player.current_health = 5
	var revision := int(_world.get("generation_revision"))
	_main.call("_load_slot", "manual_1")
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_int(int(_world.get("generation_revision"))).is_equal(revision + 1)
	assert_vector(_player.global_position).is_equal(ExplorationGenerator.HUB_SPAWN)
	assert_int(_player.current_health).is_equal(100)
	assert_int(progression.gold).is_equal(431)
	assert_int(inventory.item_counts[0]).is_equal(3)
	assert_str((inventory.get_node("Panel/Contents/Gold") as Label).text).is_equal("Золото: 431")
	assert_int(_world.find_children("*", "GoldPickup", true, false).size()).is_equal(0)
	assert_int(_world.find_children("*", "WorldItem", true, false).size()).is_equal(0)
	assert_int(_world.find_children("*", "BasicProjectile", true, false).size()).is_equal(0)
	var new_cache := _world.find_children("*", "MapCache", true, false)[0] as MapCache
	assert_bool(new_cache.opened).is_false()
	assert_bool(new_cache.get_instance_id() != old_cache_id).is_true()
	assert_bool(_navigation.find_path(_player.global_position, new_cache.global_position, false, _player).is_empty()).is_false()
	assert_bool(new_cache.interact(_player, progression, _navigation)).is_true()

func test_new_game_runs_fresh_generation_without_changing_the_hub() -> void:
	var revision := int(_world.get("generation_revision"))
	var cache := _world.find_children("*", "MapCache", true, false)[0] as MapCache
	var old_cache_id := cache.get_instance_id()
	_main.call("_start_new_game")
	await get_tree().physics_frame
	assert_int(int(_world.get("generation_revision"))).is_equal(revision + 1)
	assert_vector(_player.global_position).is_equal(ExplorationGenerator.HUB_SPAWN)
	assert_bool((_world.get_node("Hub/Ground") as Polygon2D).polygon == _hub_polygon).is_true()
	var new_cache := _world.find_children("*", "MapCache", true, false)[0] as MapCache
	assert_bool(new_cache.get_instance_id() != old_cache_id).is_true()

func _crossings_use_passage(path: PackedVector2Array, boundary_x: float, passage_y: float) -> bool:
	var crossed := false
	for index in range(1, path.size()):
		var from := path[index - 1]
		var to := path[index]
		if (from.x - boundary_x) * (to.x - boundary_x) < 0:
			crossed = true
			var crossing_y := lerpf(from.y, to.y, (boundary_x - from.x) / (to.x - from.x))
			if absf(crossing_y - passage_y) > 24.0:
				return false
	return crossed
