extends GdUnitTestSuite

func test_keyboard_actions_are_bound_to_q_and_one() -> void:
	assert_bool(InputMap.has_action("cast_cursor_ability")).is_true()
	assert_bool(InputMap.has_action("use_health_potion")).is_true()
	var ability_events := InputMap.action_get_events("cast_cursor_ability")
	var potion_events := InputMap.action_get_events("use_health_potion")
	assert_bool(_has_physical_key(ability_events, KEY_Q)).is_true()
	assert_bool(_has_physical_key(potion_events, KEY_1)).is_true()

func test_cursor_ability_hits_enemy_and_obeys_cooldown() -> void:
	var main := _create_main()
	if main == null:
		return
	var world := main.get_node("World")
	var player := world.get_node("Hub/Player") as PlayerActor
	var enemy := world.get_node("Exploration/TrainingSentinel") as EnemyActor
	var ability := world.get_node("AbilityController") as AbilityController
	player.global_position = enemy.global_position - Vector2(80, 0)
	assert_int(player.current_health).is_equal(50)
	assert_int(player.max_health).is_equal(100)
	assert_bool(ability.cast_toward(enemy.global_position)).is_true()
	assert_float(ability.cooldown_remaining).is_equal_approx(3.0, 0.001)
	assert_bool(ability.cast_toward(enemy.global_position)).is_false()
	for _frame in range(24):
		await get_tree().physics_frame
	assert_int(enemy.current_health).is_equal(3)
	main.queue_free()

func test_cursor_ability_projectile_is_blocked_by_world_wall() -> void:
	var main := _create_main()
	if main == null:
		return
	var world := main.get_node("World")
	var player := world.get_node("Hub/Player") as PlayerActor
	var enemy := world.get_node("Exploration/TrainingSentinel") as EnemyActor
	var ability := world.get_node("AbilityController") as AbilityController
	player.global_position = Vector2(130, 0)
	assert_bool(ability.cast_toward(enemy.global_position)).is_true()
	for _frame in range(24):
		await get_tree().physics_frame
	assert_int(enemy.current_health).is_equal(5)
	main.queue_free()

func test_health_potion_restores_health_consumes_one_and_updates_hud() -> void:
	var main := _create_main()
	if main == null:
		return
	var world := main.get_node("World")
	var player := world.get_node("Hub/Player") as PlayerActor
	var inventory := world.get_node("Inventory") as InventoryController
	var potion := load("res://data/items/health_potion.tres") as ItemDefinition
	assert_bool(inventory.add_item(potion, 2)).is_true()
	assert_bool(world.call("use_health_potion")).is_true()
	assert_int(player.current_health).is_equal(100)
	assert_int(inventory.item_counts[0]).is_equal(1)
	var health_bar := world.get_node("PlayerHUD").get_child(0).get_child(1) as ProgressBar
	assert_float(health_bar.value).is_equal(100.0)
	assert_bool(world.call("use_health_potion")).is_false()
	assert_int(inventory.item_counts[0]).is_equal(1)
	main.queue_free()

func test_health_potion_requires_item_and_does_not_overheal() -> void:
	var main := _create_main()
	if main == null:
		return
	var world := main.get_node("World")
	var player := world.get_node("Hub/Player") as PlayerActor
	var inventory := world.get_node("Inventory") as InventoryController
	var potion := load("res://data/items/health_potion.tres") as ItemDefinition
	player.current_health = 80
	assert_bool(inventory.add_item(potion)).is_true()
	assert_bool(world.call("use_health_potion")).is_true()
	assert_int(player.current_health).is_equal(100)
	assert_int(inventory.collected_items.size()).is_equal(0)
	player.current_health = 50
	assert_bool(world.call("use_health_potion")).is_false()
	assert_int(player.current_health).is_equal(50)
	main.queue_free()

func test_player_health_stays_within_zero_and_maximum() -> void:
	var main := _create_main()
	if main == null:
		return
	var player := main.get_node("World/Hub/Player") as PlayerActor
	assert_int(player.take_damage(100)).is_equal(50)
	assert_int(player.current_health).is_equal(0)
	assert_int(player.heal(150)).is_equal(100)
	assert_int(player.current_health).is_equal(100)
	main.queue_free()

func _has_physical_key(events: Array[InputEvent], keycode: int) -> bool:
	for event: InputEvent in events:
		var key_event := event as InputEventKey
		if key_event != null and key_event.physical_keycode == keycode:
			return true
	return false

func _create_main() -> Node:
	var packed_scene := load("res://scenes/main/main.tscn") as PackedScene
	if packed_scene == null:
		return null
	var main := packed_scene.instantiate()
	add_child(main)
	main.call("_start_new_game")
	return main
