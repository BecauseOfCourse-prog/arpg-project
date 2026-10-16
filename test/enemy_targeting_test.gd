extends GdUnitTestSuite

func test_opaque_sprite_edges_select_enemy_and_transparent_pixels_do_not() -> void:
	var world := auto_free((load("res://scenes/world/world.tscn") as PackedScene).instantiate()) as Node
	world.procedural_generation_enabled = false
	add_child(world)
	var enemy := world.get_node("Exploration/TrainingSentinel") as EnemyActor
	var player := world.get_node("Hub/Player") as PlayerActor
	var sprite := enemy.get_node("Sprite2D") as Sprite2D
	var image := sprite.texture.get_image()
	var edge_point := Vector2.ZERO
	var found_edge := false
	var transparent_point := Vector2.ZERO
	var found_transparent := false
	for y in range(0, image.get_height(), 8):
		for x in range(0, image.get_width(), 8):
			var local_point := Vector2(x + 0.5, y + 0.5) - Vector2(image.get_size()) / 2.0
			var point := sprite.to_global(local_point)
			if image.get_pixel(x, y).a > 0.5 and point.distance_to(enemy.global_position) > enemy.click_radius + 2:
				edge_point = point
				found_edge = true
			if image.get_pixel(x, y).a == 0 and point.distance_to(enemy.global_position) > enemy.click_radius:
				transparent_point = point
				found_transparent = true
	assert_bool(found_edge).is_true()
	assert_bool(found_transparent).is_true()
	assert_bool(enemy.contains_attack_point(edge_point)).is_true()
	assert_object(player.call("_enemy_at", edge_point)).is_same(enemy)
	var attacks: Array[EnemyActor] = []
	player.attack_requested.connect(func(target: EnemyActor) -> void: attacks.append(target))
	player.call("_issue_pointer_command", edge_point)
	assert_array(attacks).is_equal([enemy])
	assert_bool(enemy.contains_attack_point(transparent_point)).is_false()
	assert_object(player.call("_enemy_at", transparent_point)).is_null()
	assert_bool(enemy.contains_attack_point(enemy.global_position + Vector2(100, 100))).is_false()
	var sprite_point := sprite.to_local(edge_point)
	enemy.rotation = 0.35
	enemy.scale = Vector2(1.3, 0.8)
	assert_bool(enemy.contains_attack_point(sprite.to_global(sprite_point))).is_true()
	enemy.take_damage(enemy.current_health)
	assert_bool(enemy.contains_attack_point(sprite.to_global(sprite_point))).is_false()
	assert_object(player.call("_enemy_at", sprite.to_global(sprite_point))).is_null()

func test_textureless_enemy_uses_radius_fallback() -> void:
	var enemy := auto_free(EnemyActor.new()) as EnemyActor
	add_child(enemy)
	assert_bool(enemy.contains_attack_point(Vector2(10, 0))).is_true()
	assert_bool(enemy.contains_attack_point(Vector2(30, 0))).is_false()
