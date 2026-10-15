extends GdUnitTestSuite

var _manager: Node

func before_test() -> void:
	_manager = get_node("/root/SaveManager")
	_manager.set("storage_directory", "user://gdunit_save_tests_%d" % Time.get_ticks_usec())

func after_test() -> void:
	var directory_path := ProjectSettings.globalize_path(_manager.get("storage_directory"))
	var directory := DirAccess.open(directory_path)
	if directory != null:
		for file_name: String in directory.get_files():
			DirAccess.remove_absolute(directory_path.path_join(file_name))
		DirAccess.remove_absolute(directory_path)
	_manager.call("clear_pending_game_data")
	_manager.set("storage_directory", "user://saves")

func test_manual_and_autosave_slots_are_separate_and_round_trip_owned_state() -> void:
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	add_child(main)
	main.call("_start_new_game")
	var world := main.get_node("World")
	var inventory := world.get_node("Inventory") as InventoryController
	var progression := world.get_node("PlayerProgression") as PlayerProgression
	var pause_menu := world.get_node("PauseMenu") as PauseMenu
	var potion := load("res://data/items/health_potion.tres") as ItemDefinition
	progression.gold = 381
	assert_bool(inventory.add_item(potion, 7)).is_true()
	pause_menu.open_menu()
	assert_bool(get_tree().paused).is_true()
	pause_menu.call("_save_to_slot", "manual_1")
	pause_menu.call("_resume")
	assert_bool(get_tree().paused).is_false()
	assert_bool(world.call("save_manual", "manual_2")).is_true()
	assert_bool(world.call("save_manual", "manual_3")).is_true()
	assert_bool(world.call("save_manual", "autosave")).is_false()
	assert_bool(world.call("save_important_milestone")).is_true()
	assert_str(_manager.call("get_slot_info", "manual_1").get("status")).is_equal("available")
	assert_str(_manager.call("get_slot_info", "autosave").get("status")).is_equal("available")
	progression.gold = 1
	inventory.remove_item_at(0)
	var player := world.get_node("Hub/Player") as PlayerActor
	player.current_health = 10
	main.call("_load_slot", "manual_1")
	assert_int(progression.gold).is_equal(381)
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_int(inventory.item_counts[0]).is_equal(7)
	assert_int(player.current_health).is_equal(100)
	main.queue_free()

func test_corrupted_and_incompatible_slots_are_unavailable_without_affecting_valid_slots() -> void:
	var payload := _valid_payload()
	assert_bool(_manager.call("save_manual", "manual_1", payload)).is_true()
	var corrupt_path := ProjectSettings.globalize_path(_manager.call("_slot_path", "manual_2"))
	_write_text(corrupt_path, "{not valid json")
	var incompatible_path := ProjectSettings.globalize_path(_manager.call("_slot_path", "autosave"))
	_write_text(incompatible_path, JSON.stringify({"schema_version": 999, "payload": payload}))
	assert_str(_manager.call("get_slot_info", "manual_1").get("status")).is_equal("available")
	assert_str(_manager.call("get_slot_info", "manual_2").get("status")).is_equal("unavailable")
	assert_str(_manager.call("get_slot_info", "autosave").get("status")).is_equal("unavailable")
	assert_bool(_manager.call("load_slot", "manual_2")).is_false()

func test_invalid_inventory_snapshot_does_not_partially_restore() -> void:
	var inventory := InventoryController.new()
	var bow := load("res://data/items/emberwood_bow.tres") as ItemDefinition
	assert_bool(inventory.add_item(bow)).is_true()
	var snapshot_items: Array = inventory.collected_items.duplicate()
	var snapshot_positions: Array = inventory.item_positions.duplicate()
	var snapshot_counts: Array = inventory.item_counts.duplicate()
	assert_bool(inventory.restore_items(["res://data/items/missing.tres"], [[0, 0]], [1])).is_false()
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_object(inventory.collected_items[0]).is_same(snapshot_items[0])
	assert_bool(inventory.item_positions[0] == snapshot_positions[0]).is_true()
	assert_int(inventory.item_counts[0]).is_equal(snapshot_counts[0])
	inventory.free()

func test_empty_slots_and_malformed_payloads_are_rejected() -> void:
	assert_str(_manager.call("get_slot_info", "manual_1").get("status")).is_equal("empty")
	assert_bool(_manager.call("save_manual", "invalid_slot", _valid_payload())).is_false()
	assert_bool(_manager.call("save_manual", "manual_1", {"gold": -1, "items": [], "positions": [], "counts": []})).is_false()
	assert_bool(_manager.call("save_manual", "manual_1", {"gold": 0, "items": ["res://data/items/emberwood_bow.tres"], "positions": [[0, 0]], "counts": [1]})).is_true()
	var slot_path: String = ProjectSettings.globalize_path(_manager.call("_slot_path", "manual_1"))
	var file := FileAccess.open(slot_path, FileAccess.READ)
	var envelope: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	envelope["payload"]["positions"] = [["bad", 0]]
	_write_text(slot_path, JSON.stringify(envelope))
	assert_str(_manager.call("get_slot_info", "manual_1").get("status")).is_equal("unavailable")

func test_missing_slot_recovers_valid_backup() -> void:
	var payload := _valid_payload()
	assert_bool(_manager.call("save_manual", "manual_1", payload)).is_true()
	var slot_path := ProjectSettings.globalize_path(_manager.call("_slot_path", "manual_1"))
	var backup_path := slot_path + ".bak"
	assert_int(DirAccess.rename_absolute(slot_path, backup_path)).is_equal(OK)

	var recovered: Dictionary = _manager.call("get_slot_info", "manual_1")
	assert_str(recovered.get("status")).is_equal("available")
	assert_int(int(recovered.get("payload", {}).get("gold", -1))).is_equal(12)
	assert_bool(FileAccess.file_exists(slot_path)).is_true()
	assert_bool(FileAccess.file_exists(backup_path)).is_false()

func test_corrupt_slot_recovers_valid_backup() -> void:
	var payload := _valid_payload()
	assert_bool(_manager.call("save_manual", "manual_1", payload)).is_true()
	var slot_path := ProjectSettings.globalize_path(_manager.call("_slot_path", "manual_1"))
	var backup_path := slot_path + ".bak"
	_write_text(backup_path, FileAccess.get_file_as_string(slot_path))
	_write_text(slot_path, "{interrupted write")

	var recovered: Dictionary = _manager.call("get_slot_info", "manual_1")
	assert_str(recovered.get("status")).is_equal("available")
	assert_int(int(recovered.get("payload", {}).get("gold", -1))).is_equal(12)
	assert_bool(FileAccess.file_exists(slot_path)).is_true()
	assert_bool(FileAccess.file_exists(backup_path)).is_false()

func _valid_payload() -> Dictionary:
	return {
		"gold": 12,
		"items": ["res://data/items/emberwood_bow.tres"],
		"positions": [[0, 0]],
		"counts": [1],
		"quests": {},
	}

func _write_text(path: String, value: String) -> void:
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(value)
	file.close()
