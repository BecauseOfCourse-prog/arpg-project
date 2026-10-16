extends GdUnitTestSuite

func _world() -> Node:
	var main := auto_free((load("res://scenes/main/main.tscn") as PackedScene).instantiate()) as Node
	add_child(main)
	main.call("_start_new_game")
	main.get_node("World").game_clock.active = false
	return main.get_node("World")

func test_exhaustion_reopen_sales_and_independent_buyback() -> void:
	var world := _world()
	var limited := world.get_node("LimitedVendorService") as VendorService
	var unlimited := world.get_node("VendorService") as VendorService
	var window := world.get_node("VendorWindow") as VendorWindow
	assert_int(limited.remaining_stock(0)).is_equal(1)
	window.open_vendor(limited)
	assert_bool(limited.buy(0)).is_true()
	assert_int(limited.progression.gold).is_equal(50)
	assert_bool(limited.buy(0)).is_false()
	window.hide()
	window.open_vendor(limited)
	assert_int(limited.remaining_stock(0)).is_zero()
	assert_bool(limited.sell(0)).is_true()
	assert_int(limited.remaining_stock(0)).is_zero()
	assert_int(limited.buyback_entries.size()).is_equal(1)
	assert_int(unlimited.buyback_entries.size()).is_zero()
	assert_bool(limited.buyback(0)).is_true()
	assert_int(limited.remaining_stock(0)).is_zero()
	assert_bool((world.get_node("Hub/LimitedVendor/Visual") as Polygon2D).color != (world.get_node("Hub/Vendor/Visual") as Polygon2D).color).is_true()

func test_daily_refresh_deferral_and_pending_save_restore() -> void:
	var world := _world()
	var service := world.get_node("LimitedVendorService") as VendorService
	var window := world.get_node("VendorWindow") as VendorWindow
	var clock: GameClock = world.game_clock
	assert_bool(service.buy(0)).is_true()
	window.open_vendor(service)
	clock.advance(1320.0)
	assert_int(service.remaining_stock(0)).is_zero()
	assert_int(clock.pending_vendor_day).is_equal(2)
	var saved: Dictionary = world.call("_build_save_payload")
	var manager := get_node("/root/SaveManager")
	assert_bool(manager.call("_is_valid_payload", saved)).is_true()
	window.hide()
	assert_int(service.remaining_stock(0)).is_equal(1)
	manager.set("pending_game_data", saved.duplicate(true))
	world.call("_restore_pending_game")
	assert_int(service.remaining_stock(0)).is_equal(1)
	assert_int(service.current_day).is_equal(2)
	assert_int(clock.pending_vendor_day).is_equal(-1)
	assert_bool(service.buy(0)).is_true()
	clock.set_trading_open(false)
	assert_int(service.remaining_stock(0)).is_zero()
	clock.advance(4320.0)
	assert_int(service.remaining_stock(0)).is_equal(1)
	clock.advance(1440.0)
	assert_int(service.remaining_stock(0)).is_equal(1)

func test_potion_types_healing_and_key_two() -> void:
	var world := _world()
	var inventory := world.get_node("Inventory") as InventoryController
	var player := world.get_node("Hub/Player") as PlayerActor
	var potion := preload("res://data/items/enhanced_health_potion.tres")
	assert_bool(inventory.add_item(potion, 2)).is_true()
	player.current_health = 1
	assert_bool(world.call("use_health_potion")).is_false()
	assert_bool(world.call("use_health_potion", "enhanced_health_potion")).is_true()
	assert_int(player.current_health).is_equal(100)
	assert_int(inventory.item_counts[0]).is_equal(1)
	assert_bool(world.call("use_health_potion", "enhanced_health_potion")).is_false()
	player.current_health = 10
	var event := InputEventKey.new()
	event.physical_keycode = KEY_2
	event.pressed = true
	assert_bool(event.is_action_pressed("use_enhanced_health_potion")).is_true()
	world.call("_unhandled_input", event)
	assert_int(player.current_health).is_equal(100)
	assert_int(inventory.collected_items.size()).is_zero()
	assert_bool(inventory.add_item(preload("res://data/items/health_potion.tres"))).is_true()
	player.current_health = 10
	assert_bool(world.call("use_health_potion", "enhanced_health_potion")).is_false()
	assert_bool(world.call("use_health_potion")).is_true()
	assert_int(player.current_health).is_equal(60)

func test_stock_round_trips_and_invalid_saves() -> void:
	var world := _world()
	var service := world.get_node("LimitedVendorService") as VendorService
	var manager := get_node("/root/SaveManager")
	for quantity: int in [1, 0]:
		if quantity == 0:
			assert_bool(service.buy(0)).is_true()
		var saved: Dictionary = world.call("_build_save_payload")
		assert_bool(manager.call("_is_valid_payload", saved)).is_true()
		service.advance_day(2)
		manager.set("pending_game_data", saved.duplicate(true))
		world.call("_restore_pending_game")
		assert_int(service.remaining_stock(0)).is_equal(quantity)
		assert_int(service.current_day).is_equal(1)
	var valid: Dictionary = world.call("_build_save_payload")
	for invalid: Dictionary in [{"day": 1, "quantities": [2]}, {"day": 1, "quantities": [-1]}, {"day": 1, "quantities": [0.5]}, {"day": 2, "quantities": [1]}, {"day": 1, "quantities": []}]:
		var payload := valid.duplicate(true)
		payload.limited_vendor = invalid
		assert_bool(manager.call("_is_valid_payload", payload)).is_false()

func test_failed_purchases_leave_finite_offer_unchanged() -> void:
	var world := _world()
	var service := world.get_node("LimitedVendorService") as VendorService
	service.progression.gold = 49
	assert_bool(service.buy(0)).is_false()
	assert_int(service.progression.gold).is_equal(49)
	assert_int(service.inventory.collected_items.size()).is_zero()
	assert_int(service.remaining_stock(0)).is_equal(1)
	service.progression.gold = 100
	for index in range(40):
		assert_bool(service.inventory.add_item(_filler())).is_true()
	assert_bool(service.buy(0)).is_false()
	assert_int(service.progression.gold).is_equal(100)
	assert_int(service.inventory.collected_items.size()).is_equal(40)
	assert_int(service.remaining_stock(0)).is_equal(1)

func _filler() -> ItemDefinition:
	var item := ItemDefinition.new()
	item.inventory_width = 1
	item.inventory_height = 1
	return item

func test_file_save_round_trip_and_legacy_initialization() -> void:
	var world := _world()
	var service := world.get_node("LimitedVendorService") as VendorService
	var manager := load("res://scripts/session/save_manager.gd").new() as Node
	manager.storage_directory = "res://reports/limited_vendor_saves"
	assert_bool(service.buy(0)).is_true()
	var payload: Dictionary = world.call("_build_save_payload")
	assert_bool(manager.save_manual("manual_1", payload)).is_true()
	assert_bool(manager.load_slot("manual_1")).is_true()
	get_node("/root/SaveManager").pending_game_data = manager.pending_game_data
	world.call("_restore_pending_game")
	assert_int(service.remaining_stock(0)).is_zero()
	payload.erase("limited_vendor")
	payload.game_time = {"day": 4, "minute": 100.0, "pending_vendor_day": -1}
	get_node("/root/SaveManager").pending_game_data = payload
	world.call("_restore_pending_game")
	assert_int(service.remaining_stock(0)).is_equal(1)
	assert_int(service.current_day).is_equal(3)
	world.call("start_new_game")
	assert_int(service.current_day).is_equal(1)
	assert_int(service.remaining_stock(0)).is_equal(1)
	manager.free()

func test_approach_opens_alchemist_and_captures_presentation() -> void:
	var world := _world()
	var vendor := world.get_node("Hub/LimitedVendor") as VendorInteractable
	var player := world.get_node("Hub/Player") as PlayerActor
	var window := world.get_node("VendorWindow") as VendorWindow
	player.call("_issue_pointer_command", vendor.global_position)
	for frame in range(120):
		await get_tree().physics_frame
		if window.visible:
			break
	assert_bool(window.visible).is_true()
	assert_object(window.service).is_same(world.get_node("LimitedVendorService"))
	assert_float(player.global_position.distance_to(vendor.global_position)).is_less_equal(40.0)
	window.call("_on_grid_item_clicked", 0)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var grid := window.get("_offer_grid") as VendorGridView
	assert_int(grid.call("_item_index_at", Vector2(16, 16))).is_equal(-1)
	assert_bool((window.get("_status") as Label).text.contains("Товар закончился")).is_false()
	var panel := window.get("_panel") as PanelContainer
	assert_bool(panel.get_global_rect().end.x <= get_viewport().get_visible_rect().end.x).is_true()
	DirAccess.make_dir_recursive_absolute("res://reports")
	assert_int(get_viewport().get_texture().get_image().save_png("res://reports/limited-vendor.png")).is_equal(OK)
	window.hide()
	window.open_vendor(world.get_node("LimitedVendorService"))
	assert_int(grid.call("_item_index_at", Vector2(16, 16))).is_equal(-1)
	world.game_clock.advance(1320.0)
	assert_int(grid.call("_item_index_at", Vector2(16, 16))).is_equal(-1)
	window.hide()
	window.open_vendor(world.get_node("LimitedVendorService"))
	assert_int(grid.call("_item_index_at", Vector2(16, 16))).is_equal(0)

func test_hidden_offer_preserves_later_catalog_purchase_index() -> void:
	var world := _world()
	var service := world.get_node("LimitedVendorService") as VendorService
	var definition := VendorDefinition.new()
	definition.stock_mode = VendorDefinition.StockMode.DAILY_LIMITED
	var empty := VendorOffer.new()
	empty.item = preload("res://data/items/health_potion.tres")
	empty.stock_quantity = 0
	var available := VendorOffer.new()
	available.item = preload("res://data/items/enhanced_health_potion.tres")
	available.stock_quantity = 1
	available.purchase_price = 50
	definition.offers = [empty, available]
	service.configure(definition, service.inventory, service.progression)
	var window := world.get_node("VendorWindow") as VendorWindow
	window.open_vendor(service)
	var grid := window.get("_offer_grid") as VendorGridView
	assert_int(grid.call("_item_index_at", Vector2(16, 16))).is_equal(1)
	var click := InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = Vector2(16, 16)
	grid.call("_gui_input", click)
	assert_int(service.inventory.find_item_index_by_id("enhanced_health_potion")).is_equal(0)
	assert_int(service.progression.gold).is_equal(50)
	assert_int(grid.call("_item_index_at", Vector2(16, 16))).is_equal(-1)
