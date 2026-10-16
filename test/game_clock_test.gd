extends GdUnitTestSuite

func test_saved_day_limit_accepts_boundary_and_rejects_overflow_without_mutation() -> void:
	var clock := auto_free(GameClock.new()) as GameClock
	var boundary := {"day": 100_000, "minute": 480.5, "pending_vendor_day": 100_000}
	assert_bool(GameClock.valid_snapshot(boundary)).is_true()
	assert_bool(clock.restore(boundary)).is_true()
	assert_int(clock.day).is_equal(100_000)
	assert_int(clock.pending_vendor_day).is_equal(100_000)
	for invalid_day: Variant in [0, -1, 100_001, 1e30]:
		var invalid := boundary.duplicate()
		invalid["day"] = invalid_day
		assert_bool(GameClock.valid_snapshot(invalid)).is_false()
		assert_bool(clock.restore(invalid)).is_false()
		assert_int(clock.day).is_equal(100_000)
		assert_float(clock.minute).is_equal(480.5)
	var invalid_pending := boundary.duplicate()
	invalid_pending["pending_vendor_day"] = 100_001
	assert_bool(clock.restore(invalid_pending)).is_false()
	clock.minute = 1439.0
	clock.advance(10.0)
	assert_int(clock.day).is_equal(100_000)
	assert_bool(clock.minute < 1440.0).is_true()
	assert_bool(GameClock.valid_snapshot(clock.snapshot())).is_true()
	var last_minute := clock.minute
	clock.advance(1440.0)
	assert_float(clock.minute).is_equal(last_minute)

func test_period_boundaries_midnight_and_rate() -> void:
	var clock := auto_free(GameClock.new()) as GameClock
	assert_int(clock.day).is_equal(1)
	assert_float(clock.minute).is_equal(480.0)
	clock.advance(60.5)
	assert_float(clock.minute).is_equal(540.5)
	for entry: Array in [[359.0, "Night"], [360.0, "Morning"], [600.0, "Day"], [1080.0, "Evening"], [1320.0, "Night"]]:
		clock.minute = entry[0]
		assert_str(clock.period()).is_equal(entry[1])
	clock.minute = 1439.5
	clock.advance(1.0)
	assert_int(clock.day).is_equal(2)
	assert_float(clock.minute).is_equal(0.5)

func test_refresh_crossing_deferral_and_restore_do_not_duplicate_events() -> void:
	var clock := auto_free(GameClock.new()) as GameClock
	var events: Array[int] = []
	clock.vendor_refresh_due.connect(func(day: int) -> void: events.append(day))
	clock.minute = 359.0
	clock.advance(1.0)
	assert_array(events).is_equal([1])
	clock.advance(0.5)
	assert_int(events.size()).is_equal(1)
	clock.set_trading_open(true)
	clock.advance(2880.0)
	assert_int(events.size()).is_equal(1)
	var saved := clock.snapshot()
	assert_bool(clock.restore(saved)).is_true()
	assert_int(events.size()).is_equal(1)
	clock.set_trading_open(false)
	assert_array(events).is_equal([1, 3])
	clock.set_trading_open(false)
	assert_int(events.size()).is_equal(2)

func test_clock_validation_and_continuous_lighting() -> void:
	var clock := auto_free(GameClock.new()) as GameClock
	for invalid: Dictionary in [{"day": 0, "minute": 480, "pending_vendor_day": -1}, {"day": 1, "minute": 1440, "pending_vendor_day": -1}, {"day": 1, "minute": "480", "pending_vendor_day": -1}]:
		assert_bool(clock.restore(invalid)).is_false()
	for boundary: float in [360.0, 600.0, 1080.0, 1320.0]:
		clock.minute = boundary - 0.001
		var before := clock.lighting()
		clock.minute = boundary + 0.001
		assert_bool(before.is_equal_approx(clock.lighting())).is_true()

func test_session_pause_menu_and_inventory_time_behavior() -> void:
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	add_child(main)
	var world := main.get_node("World")
	var clock: GameClock = world.game_clock
	await get_tree().process_frame
	assert_float(clock.minute).is_equal(480.0)
	main.call("_start_new_game")
	var start := clock.minute
	await await_millis(100)
	assert_bool(clock.minute > start).is_true()
	var pause_menu := world.get_node("PauseMenu") as PauseMenu
	pause_menu.open_menu()
	start = clock.minute
	await get_tree().create_timer(0.1, true).timeout
	assert_float(clock.minute).is_equal(start)
	pause_menu.call("_resume")
	(world.get_node("VendorWindow") as VendorWindow).visible = true
	start = clock.minute
	await await_millis(100)
	assert_bool(clock.minute > start).is_true()
	main.free()
