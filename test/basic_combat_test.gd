extends GdUnitTestSuite

func test_target_command_moves_player_and_projectile_damages_enemy() -> void:
	var main := _create_main()
	if main == null:
		return
	var player := main.get_node_or_null("World/Hub/Player") as PlayerActor
	var enemy := main.get_node_or_null("World/Exploration/TrainingSentinel") as EnemyActor
	assert_object(player).is_not_null()
	assert_object(enemy).is_not_null()
	if player == null or enemy == null:
		main.queue_free()
		return
	await get_tree().physics_frame
	var start := player.global_position
	player._issue_pointer_command(enemy.global_position)
	for _frame in range(35):
		await get_tree().physics_frame
	assert_bool(player.global_position.distance_to(start) > 0.0).is_true()
	assert_bool(player.global_position.distance_to(enemy.global_position) < start.distance_to(enemy.global_position)).is_true()
	main.queue_free()

func test_attack_repeats_until_movement_command_and_defeat_drops_one_item() -> void:
	var main := _create_main()
	if main == null:
		return
	var world := main.get_node("World")
	var player := main.get_node("World/Hub/Player") as PlayerActor
	var enemy := main.get_node("World/Exploration/TrainingSentinel") as EnemyActor
	if player == null or enemy == null:
		main.queue_free()
		return
	player.definition = player.definition.duplicate() as PlayerDefinition
	player.definition.basic_attack_interval = 0.05
	player.global_position = enemy.global_position - Vector2(80, 0)
	await get_tree().physics_frame
	player._issue_pointer_command(enemy.global_position)
	for _frame in range(130):
		await get_tree().physics_frame
		if enemy.is_defeated:
			break
	assert_bool(enemy.is_defeated).is_true()
	await get_tree().physics_frame
	var dropped_items := world.find_children("*", "WorldItem", true, false)
	assert_int(dropped_items.size()).is_equal(1)
	var navigation := world.get_node("NavigationGrid") as NavigationGrid
	var drop := dropped_items[0] as WorldItem
	assert_bool(navigation.is_point_on_ground(drop.global_position)).is_true()
	main.queue_free()

func test_default_attack_cadence_is_one_hit_per_second() -> void:
	var main := _create_main()
	if main == null:
		return
	var player := main.get_node("World/Hub/Player") as PlayerActor
	var enemy := main.get_node("World/Exploration/TrainingSentinel") as EnemyActor
	if player == null or enemy == null:
		main.queue_free()
		return
	player.global_position = enemy.global_position - Vector2(80, 0)
	await get_tree().physics_frame
	player._issue_pointer_command(enemy.global_position)
	for _frame in range(20):
		await get_tree().physics_frame
		if enemy.current_health < 5:
			break
	assert_int(enemy.current_health).is_equal(4)
	for _frame in range(35):
		await get_tree().physics_frame
	assert_int(enemy.current_health).is_equal(4)
	for _frame in range(25):
		await get_tree().physics_frame
	assert_int(enemy.current_health).is_equal(3)
	main.queue_free()

func test_repeated_clicks_cannot_increase_attack_speed() -> void:
	var main := _create_main()
	if main == null:
		return
	var player := main.get_node("World/Hub/Player") as PlayerActor
	var enemy := main.get_node("World/Exploration/TrainingSentinel") as EnemyActor
	if player == null or enemy == null:
		main.queue_free()
		return
	player.definition = player.definition.duplicate() as PlayerDefinition
	player.definition.basic_attack_interval = 0.5
	player.global_position = enemy.global_position - Vector2(80, 0)
	await get_tree().physics_frame
	for _frame in range(35):
		player._issue_pointer_command(enemy.global_position)
		await get_tree().physics_frame
	assert_int(enemy.current_health).is_equal(4)
	for _frame in range(20):
		await get_tree().physics_frame
	assert_int(enemy.current_health).is_equal(3)
	main.queue_free()

func test_movement_command_cancels_repeated_attack() -> void:
	var main := _create_main()
	if main == null:
		return
	var player := main.get_node("World/Hub/Player") as PlayerActor
	var enemy := main.get_node("World/Exploration/TrainingSentinel") as EnemyActor
	if player == null or enemy == null:
		main.queue_free()
		return
	player.definition = player.definition.duplicate() as PlayerDefinition
	player.definition.basic_attack_interval = 0.05
	player.global_position = enemy.global_position - Vector2(80, 0)
	await get_tree().physics_frame
	player._issue_pointer_command(enemy.global_position)
	for _frame in range(15):
		await get_tree().physics_frame
	player._issue_pointer_command(Vector2(-120, 80))
	for _frame in range(20):
		await get_tree().physics_frame
	var health_after_cancel := enemy.current_health
	for _frame in range(40):
		await get_tree().physics_frame
	assert_int(enemy.current_health).is_equal(health_after_cancel)
	main.queue_free()

func test_wall_blocks_projectile() -> void:
	var main := _create_main()
	if main == null:
		return
	var world := main.get_node("World")
	var enemy := main.get_node("World/Exploration/TrainingSentinel") as EnemyActor
	if enemy == null:
		main.queue_free()
		return
	var projectile := (load("res://scenes/combat/basic_projectile.tscn") as PackedScene).instantiate() as BasicProjectile
	projectile.target = enemy
	projectile.direction = Vector2.RIGHT
	projectile.global_position = Vector2(130, 0)
	world.add_child(projectile)
	for _frame in range(35):
		await get_tree().physics_frame
	assert_int(enemy.current_health).is_equal(5)
	assert_bool(is_instance_valid(projectile)).is_false()
	main.queue_free()

func test_passive_enemy_remains_stationary_without_attack_command() -> void:
	var main := _create_main()
	if main == null:
		return
	var enemy := main.get_node("World/Exploration/TrainingSentinel") as EnemyActor
	if enemy == null:
		main.queue_free()
		return
	var initial_position := enemy.global_position
	for _frame in range(60):
		await get_tree().physics_frame
	assert_vector(enemy.global_position).is_equal(initial_position)
	assert_int(enemy.current_health).is_equal(5)
	main.queue_free()

func test_touching_world_item_collects_it_and_updates_inventory_display() -> void:
	var main := _create_main()
	if main == null:
		return
	var world := main.get_node("World")
	var player := main.get_node("World/Hub/Player") as PlayerActor
	var inventory: Node = main.get_node("World/Inventory")
	var item := (load("res://scenes/items/world_item.tscn") as PackedScene).instantiate() as WorldItem
	assert_object(player).is_not_null()
	assert_object(inventory).is_not_null()
	assert_object(item).is_not_null()
	if player == null or inventory == null or item == null:
		main.queue_free()
		return
	item.global_position = Vector2(-120, 20)
	world.add_child(item)
	await get_tree().physics_frame
	player._issue_pointer_command(item.global_position)
	for _frame in range(60):
		await get_tree().physics_frame
		if (inventory.get("collected_items") as Array).size() > 0:
			break
	await get_tree().process_frame
	assert_int((inventory.get("collected_items") as Array).size()).is_equal(1)
	assert_bool(inventory.get_node("Panel/Contents/Items").text.contains("Emberwood Bow")).is_true()
	assert_bool(inventory.get_node("Panel/Contents/Items").text.contains("Magic")).is_true()
	assert_bool(inventory.get_node("Panel/Contents/Items").text.contains("of Cinders")).is_true()
	assert_bool(is_instance_valid(item)).is_false()
	player.command_move_to(Vector2(80, 0))
	for _frame in range(140):
		await get_tree().physics_frame
		if player.global_position.x > 0.0:
			break
	assert_bool(player.global_position.x > 0.0).is_true()
	player.command_move_to(Vector2(-80, 0))
	for _frame in range(140):
		await get_tree().physics_frame
		if player.global_position.x < 0.0:
			break
	assert_bool(player.global_position.x < 0.0).is_true()
	assert_int((inventory.get("collected_items") as Array).size()).is_equal(1)
	main.queue_free()

func _create_main() -> Node:
	var main_scene := load("res://scenes/main/main.tscn") as PackedScene
	assert_object(main_scene).is_not_null()
	if main_scene == null:
		return null
	var main := main_scene.instantiate()
	add_child(main)
	main.call("_start_new_game")
	return main
