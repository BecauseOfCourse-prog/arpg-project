extends GdUnitTestSuite

var _main: Node
var _world: Node
var _player: PlayerActor
var _inventory: InventoryController
var _item: WorldItem

func before_test() -> void:
	_main = WorldTestFixture.create_main()
	add_child(_main)
	_main.call("_start_new_game")
	_world = _main.get_node("World")
	_player = _world.get_node("Hub/Player") as PlayerActor
	_inventory = _world.get_node("Inventory") as InventoryController
	_item = (load("res://scenes/items/world_item.tscn") as PackedScene).instantiate() as WorldItem
	_item.position = Vector2(-120, 20)
	_world.add_child(_item)

func after_test() -> void:
	_main.free()

func test_overlap_does_not_collect_and_clicking_label_collects_once() -> void:
	_player.global_position = _item.global_position
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_int(_inventory.collected_items.size()).is_zero()
	assert_bool(is_instance_valid(_item)).is_true()
	var label := _item.get_node("ItemName") as Label
	assert_str(label.text).is_equal("Emberwood Bow")
	var label_point: Vector2 = label.get_global_transform() * Vector2(4, label.size.y / 2.0)
	assert_bool(label_point.distance_to(_item.global_position) > _item.click_radius).is_true()
	assert_object(_player.call("_interactable_at", label_point)).is_same(_item)
	await get_tree().process_frame
	RenderingServer.force_draw(false)
	DirAccess.make_dir_recursive_absolute("res://reports")
	assert_int(get_viewport().get_texture().get_image().save_png("res://reports/ground-loot.png")).is_equal(OK)
	_button(label_point, true)
	_button(label_point, false)
	await get_tree().physics_frame
	await get_tree().process_frame
	assert_int(_inventory.collected_items.size()).is_equal(1)
	assert_bool(is_instance_valid(_item)).is_false()

func test_distant_click_approaches_and_full_inventory_allows_retry() -> void:
	_player.global_position = Vector2(-240, 0)
	var filler := ItemDefinition.new()
	filler.inventory_width = 1
	filler.inventory_height = 1
	for index in range(40):
		assert_bool(_inventory.add_item(filler)).is_true()
	_player.call("_issue_pointer_command", _item.global_position)
	assert_bool(_player.is_moving()).is_true()
	for frame in range(120):
		await get_tree().physics_frame
		if not _player.is_moving():
			break
	assert_bool(is_instance_valid(_item)).is_true()
	assert_bool(_item.collected).is_false()
	assert_int(_inventory.collected_items.size()).is_equal(40)
	for index in range(40):
		_inventory.remove_item_at(0)
	assert_bool(_item.interact(_player, null, null)).is_true()
	assert_bool(_item.interact(_player, null, null)).is_false()
	assert_int(_inventory.collected_items.size()).is_equal(1)

func test_unreachable_item_is_not_collected() -> void:
	_item.global_position = Vector2(-600, 0)
	_player.call("_issue_pointer_command", _item.global_position)
	await get_tree().physics_frame
	assert_object((_world.get_node("InteractionController") as InteractionController).target).is_null()
	assert_int(_inventory.collected_items.size()).is_zero()
	assert_bool(is_instance_valid(_item)).is_true()

func test_holding_on_loot_only_moves() -> void:
	_button(_item.global_position, true)
	_player.call("_physics_process", PlayerActor.HOLD_DELAY + 0.01)
	_button(_item.global_position, false)
	for frame in range(30):
		await get_tree().physics_frame
	assert_int(_inventory.collected_items.size()).is_zero()
	assert_bool(is_instance_valid(_item)).is_true()
	assert_bool(_item.collected).is_false()

func _button(world_point: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	event.position = _player.get_canvas_transform() * world_point
	_player.call("_unhandled_input", event)
