extends Node2D

const MAIN_MENU_SCENE := "res://scenes/main/main.tscn"

var _inventory: InventoryController
var _progression: PlayerProgression
var _session_active := false

func _ready() -> void:
	var player := get_node_or_null("Hub/Player") as PlayerActor
	_inventory = get_node_or_null("Inventory") as InventoryController
	_progression = get_node_or_null("PlayerProgression") as PlayerProgression
	var service := get_node_or_null("VendorService") as VendorService
	var vendor := get_node_or_null("Hub/Vendor") as VendorInteractable
	var window := get_node_or_null("VendorWindow") as VendorWindow
	if player != null and _progression != null:
		_progression.initialize_from_definition(player.definition)
	if service != null and _inventory != null and _progression != null:
		service.configure(preload("res://data/vendors/hub_vendor.tres"), _inventory, _progression)
	if vendor != null and service != null and window != null:
		window.inventory = _inventory
		window.progression = _progression
		vendor.activated.connect(window.open_vendor.bind(service))
		if _inventory != null:
			_inventory.item_clicked.connect(window.sell_inventory_item)
	_restore_pending_game()
	var root_window := get_tree().root
	if not root_window.close_requested.is_connected(_on_window_close_requested):
		root_window.close_requested.connect(_on_window_close_requested)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		var pause_menu := get_node_or_null("PauseMenu") as PauseMenu
		if pause_menu != null:
			pause_menu.open_menu()
			get_viewport().set_input_as_handled()

func _on_window_close_requested() -> void:
	if _session_active:
		_save_autoslot()
	get_tree().quit()

func activate_session() -> void:
	_session_active = true

func save_manual(slot_id: String) -> bool:
	var manager := get_node_or_null("/root/SaveManager")
	return manager != null and manager.call("save_manual", slot_id, _build_save_payload())

func save_important_milestone() -> bool:
	return _save_autoslot()

func save_quest_completion() -> bool:
	return _save_autoslot()

func save_level_up() -> bool:
	return _save_autoslot()

func return_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)

func _save_autoslot() -> bool:
	var manager := get_node_or_null("/root/SaveManager")
	return manager != null and manager.call("save_autosave", _build_save_payload())

func _build_save_payload() -> Dictionary:
	var item_paths: Array[String] = []
	var positions: Array = []
	var counts: Array[int] = []
	if _inventory != null:
		for index in range(_inventory.collected_items.size()):
			var item := _inventory.collected_items[index]
			item_paths.append(item.resource_path)
			var position := _inventory.item_positions[index]
			positions.append([position.x, position.y])
			counts.append(_inventory.item_counts[index])
	return {
		"gold": _progression.gold if _progression != null else 0,
		"items": item_paths,
		"positions": positions,
		"counts": counts,
		"quests": {},
	}

func _restore_pending_game() -> void:
	var manager := get_node_or_null("/root/SaveManager")
	if manager == null:
		return
	var pending_data: Dictionary = manager.get("pending_game_data")
	if pending_data.is_empty():
		return
	var payload := pending_data
	if _progression == null or _inventory == null:
		return
	if not _inventory.restore_items(payload.get("items", []), payload.get("positions", []), payload.get("counts", [])):
		return
	_progression.gold = maxi(0, int(payload.get("gold", 0)))
	manager.call("clear_pending_game_data")
