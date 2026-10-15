extends GdUnitTestSuite

func test_main_menu_starts_before_world_and_new_game_enters_continuous_world() -> void:
	var packed_main: PackedScene = load("res://scenes/main/main.tscn") as PackedScene
	assert_object(packed_main).is_not_null()
	if packed_main == null:
		return

	var main: Node = packed_main.instantiate()
	add_child(main)
	var world_before_start := main.get_node("World") as Node2D
	assert_bool(world_before_start.visible).is_false()
	var menu_layer := main.get("_menu_layer") as CanvasLayer
	assert_object(menu_layer).is_not_null()
	if menu_layer != null:
		assert_int(menu_layer.layer).is_greater(1)
	assert_bool((world_before_start.get_node("Inventory") as CanvasLayer).visible).is_false()
	main.call("_start_new_game")
	assert_bool(world_before_start.visible).is_true()
	assert_int((main as Control).mouse_filter).is_equal(Control.MOUSE_FILTER_IGNORE)
	assert_bool((world_before_start.get_node("Inventory") as CanvasLayer).visible).is_true()

	var hub: WorldArea = main.get_node_or_null("World/Hub") as WorldArea
	var exploration: WorldArea = main.get_node_or_null("World/Exploration") as WorldArea
	var player: PlayerActor = main.get_node_or_null("World/Hub/Player") as PlayerActor
	var hub_ground: Polygon2D = main.get_node_or_null("World/Hub/Ground") as Polygon2D
	var exploration_ground: Polygon2D = main.get_node_or_null("World/Exploration/Ground") as Polygon2D

	assert_object(hub).is_not_null()
	assert_object(exploration).is_not_null()
	assert_object(player).is_not_null()
	assert_object(hub_ground).is_not_null()
	assert_object(exploration_ground).is_not_null()
	if hub == null or exploration == null or player == null or hub_ground == null or exploration_ground == null:
		main.queue_free()
		return

	assert_object(hub.definition).is_not_null()
	assert_object(exploration.definition).is_not_null()
	if hub.definition == null or exploration.definition == null:
		main.queue_free()
		return

	assert_bool(hub.definition.is_safe).is_true()
	assert_bool(hub.definition.connected_area_ids.has("exploration")).is_true()
	assert_bool(exploration.definition.connected_area_ids.has("hub")).is_true()
	assert_bool(hub_ground.z_index < player.z_index).is_true()
	assert_bool(exploration_ground.z_index < player.z_index).is_true()

	main.queue_free()

func test_reusable_player_enemy_and_item_scenes_load() -> void:
	var player_scene: PackedScene = load("res://scenes/actors/player.tscn") as PackedScene
	var enemy_scene: PackedScene = load("res://scenes/actors/enemy.tscn") as PackedScene
	var item_scene: PackedScene = load("res://scenes/items/world_item.tscn") as PackedScene
	var projectile_scene: PackedScene = load("res://scenes/combat/basic_projectile.tscn") as PackedScene

	assert_object(player_scene).is_not_null()
	assert_object(enemy_scene).is_not_null()
	assert_object(item_scene).is_not_null()
	assert_object(projectile_scene).is_not_null()

func test_world_mouse_click_reaches_player_after_starting_game() -> void:
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	add_child(main)
	main.call("_start_new_game")
	var player := main.get_node("World/Hub/Player") as PlayerActor
	var destination := player.global_position + Vector2(80, 40)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = player.get_global_transform_with_canvas() * player.to_local(destination)
	get_viewport().push_input(click, true)
	await get_tree().physics_frame
	assert_bool(player.is_moving()).is_true()
	main.queue_free()

func test_authored_gameplay_definitions_use_resources() -> void:
	var player: PlayerDefinition = load("res://data/characters/adventurer.tres") as PlayerDefinition
	var enemy: EnemyDefinition = load("res://data/enemies/first_enemy.tres") as EnemyDefinition
	var item: ItemDefinition = load("res://data/items/emberwood_bow.tres") as ItemDefinition
	var hub: WorldAreaDefinition = load("res://data/areas/hub.tres") as WorldAreaDefinition
	var exploration: WorldAreaDefinition = load("res://data/areas/exploration.tres") as WorldAreaDefinition

	assert_object(player).is_not_null()
	assert_object(enemy).is_not_null()
	assert_object(item).is_not_null()
	assert_object(hub).is_not_null()
	assert_object(exploration).is_not_null()
	if player == null or enemy == null or item == null or hub == null or exploration == null:
		return

	assert_str(player.display_name).is_equal("Adventurer")
	assert_str(enemy.display_name).is_equal("Training Sentinel")
	assert_int(enemy.max_health).is_equal(5)
	assert_int(player.basic_attack_damage).is_equal(1)
	assert_float(player.basic_attack_interval).is_equal(1.0)
	assert_str(item.display_name).is_equal("Emberwood Bow")
	assert_str(item.rarity).is_equal("Magic")
	assert_bool(hub.is_safe).is_true()
	assert_bool(exploration.is_safe).is_false()

func test_navigation_routes_around_wall_and_replaces_destination() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	assert_object(main_scene).is_not_null()
	if main_scene == null:
		return
	var main := main_scene.instantiate()
	add_child(main)
	main.call("_start_new_game")
	await get_tree().physics_frame
	var navigation := main.get_node_or_null("World/NavigationGrid") as NavigationGrid
	var player := main.get_node_or_null("World/Hub/Player") as PlayerActor
	assert_object(navigation).is_not_null()
	assert_object(player).is_not_null()
	if navigation == null or player == null:
		main.queue_free()
		return
	var destination := Vector2(300, 0)
	var path := navigation.find_path(player.global_position, destination, false, player)
	assert_bool(path.is_empty()).is_false()
	var routes_around_wall := false
	for waypoint in path:
		if absf(waypoint.y) > 60.0 and waypoint.x > 150.0 and waypoint.x < 220.0:
			routes_around_wall = true
	assert_bool(routes_around_wall).is_true()
	player.command_move_to(Vector2(40, 50))
	player.command_move_to(destination)
	assert_bool(player._path.is_empty()).is_false()
	if not player._path.is_empty():
		assert_vector(player._path[player._path.size() - 1]).is_equal(destination)
	var initial_position := player.global_position
	for _frame in range(6):
		await get_tree().physics_frame
	assert_bool(player.global_position.distance_to(initial_position) > 0.0).is_true()
	var held_goal := Vector2(250, 60)
	player._update_held_goal(held_goal)
	assert_bool(player._path.is_empty()).is_false()
	if not player._path.is_empty():
		assert_vector(player._path[player._path.size() - 1]).is_equal(held_goal)
	main.queue_free()

func test_enemy_click_requests_attack_and_outside_ground_resolves_boundary() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	assert_object(main_scene).is_not_null()
	if main_scene == null:
		return
	var main := main_scene.instantiate()
	add_child(main)
	main.call("_start_new_game")
	await get_tree().physics_frame
	var navigation := main.get_node_or_null("World/NavigationGrid") as NavigationGrid
	var player := main.get_node_or_null("World/Hub/Player") as PlayerActor
	var enemy_scene := load("res://scenes/actors/enemy.tscn") as PackedScene
	assert_object(navigation).is_not_null()
	assert_object(player).is_not_null()
	assert_object(enemy_scene).is_not_null()
	if navigation == null or player == null or enemy_scene == null:
		main.queue_free()
		return
	var enemy := enemy_scene.instantiate() as EnemyActor
	main.add_child(enemy)
	enemy.global_position = Vector2(-100, 30)
	await get_tree().physics_frame
	var received_attack := [false]
	player.attack_requested.connect(func(target: EnemyActor) -> void: received_attack[0] = target == enemy)
	player._issue_pointer_command(enemy.global_position)
	assert_bool(received_attack[0]).is_true()
	var boundary_path := navigation.find_path(player.global_position, Vector2(-460, 0), true, player)
	assert_bool(boundary_path.is_empty()).is_false()
	assert_bool(navigation.find_path(player.global_position, Vector2(-460, 0), false, player).is_empty()).is_true()
	main.queue_free()

func test_zones_connect_only_through_transition_passage() -> void:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	assert_object(main_scene).is_not_null()
	if main_scene == null:
		return
	var main := main_scene.instantiate()
	add_child(main)
	main.call("_start_new_game")
	await get_tree().physics_frame
	var navigation := main.get_node_or_null("World/NavigationGrid") as NavigationGrid
	var player := main.get_node_or_null("World/Hub/Player") as PlayerActor
	assert_object(navigation).is_not_null()
	assert_object(player).is_not_null()
	if navigation == null or player == null:
		main.queue_free()
		return
	var near_passage := navigation.find_path(Vector2(-50, 0), Vector2(50, 0), false, player)
	var north_of_passage := navigation.find_path(Vector2(-50, -100), Vector2(50, -100), false, player)
	assert_bool(near_passage.is_empty()).is_false()
	assert_bool(north_of_passage.is_empty()).is_false()
	var crosses_only_at_passage := true
	for index in range(north_of_passage.size() - 1):
		var from := north_of_passage[index]
		var to := north_of_passage[index + 1]
		if from.x * to.x < 0.0:
			var crossing_fraction := -from.x / (to.x - from.x)
			var crossing_y := lerpf(from.y, to.y, crossing_fraction)
			if absf(crossing_y) > 24.0:
				crosses_only_at_passage = false
	assert_bool(crosses_only_at_passage).is_true()
	assert_bool(navigation.is_point_blocked(Vector2(0, -100), player)).is_true()
	assert_bool(navigation.is_point_blocked(Vector2(0, 0), player)).is_false()
	main.queue_free()
