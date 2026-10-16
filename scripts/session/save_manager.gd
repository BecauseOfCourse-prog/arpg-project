extends Node

const SCHEMA_VERSION := 1
const SAVE_DIRECTORY := "user://saves"
const MANUAL_SLOTS := ["manual_1", "manual_2", "manual_3"]
const AUTOSAVE_SLOT := "autosave"

var pending_game_data: Dictionary = {}
var storage_directory := SAVE_DIRECTORY

func save_manual(slot_id: String, payload: Dictionary) -> bool:
	if not MANUAL_SLOTS.has(slot_id):
		return false
	return _write_slot(slot_id, payload)

func save_autosave(payload: Dictionary) -> bool:
	return _write_slot(AUTOSAVE_SLOT, payload)

func get_slot_info(slot_id: String) -> Dictionary:
	if not MANUAL_SLOTS.has(slot_id) and slot_id != AUTOSAVE_SLOT:
		return {"status": "unavailable", "reason": "Unknown slot"}
	var path := _slot_path(slot_id)
	var primary_info := _read_slot_file(path)
	if primary_info.get("status") == "available":
		return primary_info
	# A missing target or corrupt partial replacement can leave the previous save
	# in the backup. Do not roll back a valid but incompatible newer save.
	if primary_info.get("status") == "unavailable" and primary_info.get("reason") != "Corrupted save data":
		return primary_info
	var backup_path := path + ".bak"
	if not FileAccess.file_exists(backup_path):
		return primary_info
	var backup_info := _read_slot_file(backup_path)
	if backup_info.get("status") != "available":
		return backup_info if primary_info.get("status") == "empty" else primary_info
	if FileAccess.file_exists(path) and DirAccess.remove_absolute(ProjectSettings.globalize_path(path)) != OK:
		return backup_info
	var recovery_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(backup_path),
		ProjectSettings.globalize_path(path)
	)
	if recovery_error != OK:
		return backup_info
	return backup_info

func _read_slot_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {"status": "empty"}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"status": "unavailable", "reason": "Cannot read save file"}
	var parser := JSON.new()
	var parse_error := parser.parse(file.get_as_text())
	file.close()
	if parse_error != OK:
		return {"status": "unavailable", "reason": "Corrupted save data"}
	var parsed: Variant = parser.data
	if not parsed is Dictionary:
		return {"status": "unavailable", "reason": "Corrupted save data"}
	var envelope: Dictionary = parsed
	if int(envelope.get("schema_version", -1)) != SCHEMA_VERSION:
		return {"status": "unavailable", "reason": "Incompatible save version"}
	if not envelope.get("payload", null) is Dictionary:
		return {"status": "unavailable", "reason": "Corrupted save data"}
	var payload: Dictionary = envelope["payload"]
	if not _is_valid_payload(payload):
		return {"status": "unavailable", "reason": "Corrupted save data"}
	return {"status": "available", "saved_at": str(envelope.get("saved_at", "")), "payload": payload}

func load_slot(slot_id: String) -> bool:
	var info := get_slot_info(slot_id)
	if info.get("status") != "available":
		return false
	pending_game_data = info["payload"]
	return true

func clear_pending_game_data() -> void:
	pending_game_data.clear()

func _write_slot(slot_id: String, payload: Dictionary) -> bool:
	if not _is_valid_payload(payload):
		return false
	var absolute_directory := ProjectSettings.globalize_path(storage_directory)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_directory)
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		return false
	var target_path := ProjectSettings.globalize_path(_slot_path(slot_id))
	var temporary_path := target_path + ".tmp"
	var backup_path := target_path + ".bak"
	var file := FileAccess.open(temporary_path, FileAccess.WRITE)
	if file == null:
		return false
	var envelope := {
		"schema_version": SCHEMA_VERSION,
		"saved_at": Time.get_datetime_string_from_system(true),
		"payload": payload,
	}
	file.store_string(JSON.stringify(envelope))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		DirAccess.remove_absolute(temporary_path)
		return false
	if FileAccess.file_exists(backup_path):
		DirAccess.remove_absolute(backup_path)
	var had_previous := FileAccess.file_exists(target_path)
	if had_previous and DirAccess.rename_absolute(target_path, backup_path) != OK:
		DirAccess.remove_absolute(temporary_path)
		return false
	if DirAccess.rename_absolute(temporary_path, target_path) != OK:
		if had_previous:
			DirAccess.rename_absolute(backup_path, target_path)
		DirAccess.remove_absolute(temporary_path)
		return false
	if had_previous:
		DirAccess.remove_absolute(backup_path)
	return true

func _slot_path(slot_id: String) -> String:
	return "%s/%s.json" % [storage_directory, slot_id]

func _is_valid_payload(payload: Dictionary) -> bool:
	# Additive schema-1 field: older saves load at Day 1, 08:00.
	if payload.has("game_time") and not GameClock.valid_snapshot(payload["game_time"]):
		return false
	if not payload.has("gold") or not _is_whole_number(payload["gold"]) or int(payload["gold"]) < 0:
		return false
	if not payload.get("items", null) is Array:
		return false
	var items: Array = payload["items"]
	var positions: Array = payload.get("positions", [])
	var counts: Array = payload.get("counts", [])
	if positions.size() != items.size() or counts.size() != items.size():
		return false
	var occupied: Array[Array] = []
	for y in range(InventoryController.GRID_HEIGHT):
		var row: Array[bool] = []
		row.resize(InventoryController.GRID_WIDTH)
		row.fill(false)
		occupied.append(row)
	for index in range(items.size()):
		if not items[index] is String or not str(items[index]).begins_with("res://data/items/") or not str(items[index]).ends_with(".tres"):
			return false
		if not ResourceLoader.exists(str(items[index])):
			return false
		var item := ResourceLoader.load(str(items[index])) as ItemDefinition
		if item == null or not positions[index] is Array or positions[index].size() != 2:
			return false
		if not _is_whole_number(positions[index][0]) or not _is_whole_number(positions[index][1]) or not _is_whole_number(counts[index]):
			return false
		var origin := Vector2i(int(positions[index][0]), int(positions[index][1]))
		var width := clampi(item.inventory_width, 1, InventoryController.GRID_WIDTH)
		var height := clampi(item.inventory_height, 1, InventoryController.GRID_HEIGHT)
		var max_count := item.stack_limit() if item.stackable else 1
		if origin.x < 0 or origin.y < 0 or origin.x + width > InventoryController.GRID_WIDTH or origin.y + height > InventoryController.GRID_HEIGHT:
			return false
		if int(counts[index]) <= 0 or int(counts[index]) > max_count:
			return false
		for y in range(origin.y, origin.y + height):
			for x in range(origin.x, origin.x + width):
				if occupied[y][x]:
					return false
				occupied[y][x] = true
	if payload.has("quests") and not payload["quests"] is Dictionary:
		return false
	return true

func _is_whole_number(value: Variant) -> bool:
	if value is int:
		return true
	return value is float and is_equal_approx(float(value), roundf(float(value)))
