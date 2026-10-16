extends GdUnitTestSuite

func _main() -> Node:
	var main := auto_free((load("res://scenes/main/main.tscn") as PackedScene).instantiate()) as Node
	add_child(main)
	return main

func test_session_visibility_f8_and_panel_render() -> void:
	var main := _main()
	var world := main.get_node("World")
	var panel: DebugTimePanel = world.debug_time_panel
	assert_bool(panel.visible).is_false()
	main.call("_start_new_game")
	assert_bool(panel.visible).is_true()
	var event := InputEventKey.new()
	event.keycode = KEY_F8
	event.pressed = true
	panel.call("_input", event)
	assert_bool((panel.get("_panel") as Control).visible).is_true()
	await get_tree().process_frame
	RenderingServer.force_draw(false)
	assert_bool((panel.get("_panel") as Control).get_global_rect().end.x < 870).is_true()
	DirAccess.make_dir_recursive_absolute("res://reports")
	assert_int(get_viewport().get_texture().get_image().save_png("res://reports/debug-time-panel.png")).is_equal(OK)
	panel.call("_input", event)
	assert_bool((panel.get("_panel") as Control).visible).is_false()

func test_time_selection_lighting_refresh_deferral_and_save() -> void:
	var main := _main()
	main.call("_start_new_game")
	var world := main.get_node("World")
	var clock: GameClock = world.game_clock
	clock.active = false
	var panel: DebugTimePanel = world.debug_time_panel
	var vendor := world.get_node("LimitedVendorService") as VendorService
	assert_bool(vendor.buy(0)).is_true()
	panel.jump_to(18, 0)
	assert_str(clock.period()).is_equal("Evening")
	assert_bool((world.get("_daylight") as CanvasModulate).color.is_equal_approx(clock.lighting())).is_true()
	panel.jump_to(5, 59)
	assert_int(clock.day).is_equal(2)
	assert_int(vendor.remaining_stock(0)).is_zero()
	var window := world.get_node("VendorWindow") as VendorWindow
	window.open_vendor(vendor)
	panel.jump_to(6, 0)
	assert_int(clock.pending_vendor_day).is_equal(2)
	assert_int(vendor.remaining_stock(0)).is_zero()
	assert_bool(get_node("/root/SaveManager").call("_is_valid_payload", world.call("_build_save_payload"))).is_true()
	window.hide()
	assert_int(vendor.remaining_stock(0)).is_equal(1)
	assert_int(clock.pending_vendor_day).is_equal(-1)
	panel.advance_minutes(60)
	assert_float(clock.minute).is_equal_approx(420.0, 0.001)
	panel.advance_minutes(1440)
	assert_int(clock.day).is_equal(3)
	assert_float(clock.minute).is_equal_approx(420.0, 0.001)
	assert_bool((world.get("_time_label") as Label).text.contains("07:00")).is_true()

func test_freeze_manual_steps_pause_and_new_game_reset() -> void:
	var main := _main()
	main.call("_start_new_game")
	var world := main.get_node("World")
	var clock: GameClock = world.game_clock
	var panel: DebugTimePanel = world.debug_time_panel
	(panel.get("_freeze") as CheckButton).button_pressed = true
	clock.call("_process", 20.0)
	assert_float(clock.minute).is_equal_approx(480.0, 0.001)
	panel.advance_minutes(60)
	assert_float(clock.minute).is_equal_approx(540.0, 0.001)
	var pause := world.get_node("PauseMenu") as PauseMenu
	pause.open_menu()
	panel.advance_minutes(60)
	panel.jump_to(22, 0)
	assert_float(clock.minute).is_equal_approx(540.0, 0.001)
	pause.call("_resume")
	(panel.get("_freeze") as CheckButton).button_pressed = false
	clock.call("_process", 1.0)
	assert_float(clock.minute).is_equal_approx(541.0, 0.001)
	clock.debug_frozen = true
	world.call("start_new_game")
	assert_bool(clock.debug_frozen).is_false()

func test_load_resets_testing_settings_and_preserves_calendar_limits() -> void:
	var main := _main()
	main.call("_start_new_game")
	var world := main.get_node("World")
	var clock: GameClock = world.game_clock
	var panel: DebugTimePanel = world.debug_time_panel
	clock.active = false
	var saved: Dictionary = world.call("_build_save_payload")
	clock.debug_frozen = true
	get_node("/root/SaveManager").pending_game_data = saved
	world.call("_restore_pending_game")
	assert_bool(clock.debug_frozen).is_false()
	panel.jump_to(8, 0)
	assert_int(clock.day).is_equal(1)
	assert_float(clock.minute).is_equal_approx(480.0, 0.001)
	panel.jump_to(-1, 0)
	panel.jump_to(24, 0)
	panel.jump_to(12, 60)
	assert_float(clock.minute).is_equal_approx(480.0, 0.001)
	clock.day = GameClock.MAX_DAY
	clock.minute = 1439
	panel.advance_minutes(1440)
	assert_int(clock.day).is_equal(GameClock.MAX_DAY)
	assert_bool(GameClock.valid_snapshot(clock.snapshot())).is_true()
