extends Node2D

const MAIN_MENU_SCENE := "res://scenes/main/main.tscn"

# The authored layout is retained for deterministic gameplay test fixtures.
@export var procedural_generation_enabled := true

var exploration_layout: Dictionary = {}
var generation_revision := 0

var _inventory: InventoryController
var _progression: PlayerProgression
var _session_active := false
var game_clock: GameClock
var _daylight: CanvasModulate
var _time_hud: CanvasLayer
var _time_label: Label

func _setup_game_time() -> void:
	game_clock = GameClock.new()
	game_clock.name = "GameClock"
	add_child(game_clock)
	_daylight = CanvasModulate.new()
	add_child(_daylight)
	_time_hud = CanvasLayer.new()
	_time_hud.layer = 3
	_time_hud.visible = false
	add_child(_time_hud)
	_time_label = Label.new()
	_time_label.position = Vector2(380, 16)
	_time_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_time_hud.add_child(_time_label)
	game_clock.time_changed.connect(_update_game_time_view)
	var window := get_node("VendorWindow") as VendorWindow
	window.visibility_changed.connect(func() -> void: game_clock.set_trading_open(window.visible))
	_update_game_time_view()

func _update_game_time_view() -> void:
	_daylight.color = game_clock.lighting()
	var periods := {"Morning": "Утро", "Day": "День", "Evening": "Вечер", "Night": "Ночь"}
	_time_label.text = "День %d · %02d:%02d · %s" % [game_clock.day, int(game_clock.minute) / 60, int(game_clock.minute) % 60, periods[game_clock.period()]]

func _ready() -> void:
	_setup_game_time()
	var player := get_node_or_null("Hub/Player") as PlayerActor
	_inventory = get_node_or_null("Inventory") as InventoryController
	_progression = get_node_or_null("PlayerProgression") as PlayerProgression
	var service := get_node_or_null("VendorService") as VendorService
	var vendor := get_node_or_null("Hub/Vendor") as VendorInteractable
	var window := get_node_or_null("VendorWindow") as VendorWindow
	if player != null and _progression != null:
		_progression.initialize_from_definition(player.definition)
	if _inventory != null:
		_inventory.configure_progression(_progression)
	if service != null and _inventory != null and _progression != null:
		service.configure(preload("res://data/vendors/hub_vendor.tres"), _inventory, _progression)
	var limited := get_node("LimitedVendorService") as VendorService
	limited.configure(preload("res://data/vendors/limited_vendor.tres"), _inventory, _progression)
	limited.advance_day(1)
	game_clock.vendor_refresh_due.connect(limited.advance_day)
	(get_node("Hub/LimitedVendor") as VendorInteractable).activated.connect(window.open_vendor.bind(limited))
	if vendor != null and service != null and window != null:
		window.inventory = _inventory
		window.progression = _progression
		vendor.activated.connect(window.open_vendor.bind(service))
		if _inventory != null:
			_inventory.item_clicked.connect(window.sell_inventory_item)
	if procedural_generation_enabled:
		regenerate_exploration()
	_restore_pending_game()
	var root_window := get_tree().root
	if not root_window.close_requested.is_connected(_on_window_close_requested):
		root_window.close_requested.connect(_on_window_close_requested)

func _physics_process(_delta: float) -> void:
	if procedural_generation_enabled:
		_update_camera()

func start_new_game() -> void:
	game_clock.reset()
	var limited := get_node("LimitedVendorService") as VendorService
	limited.configure(preload("res://data/vendors/limited_vendor.tres"), _inventory, _progression)
	limited.current_day = 1
	limited.buyback_entries.clear()
	if procedural_generation_enabled:
		regenerate_exploration()

func regenerate_exploration(random_seed: int = -1) -> void:
	_clear_generated_session_state()
	var rng := RandomNumberGenerator.new()
	if random_seed < 0:
		rng.randomize()
	else:
		rng.seed = random_seed
	exploration_layout = ExplorationGenerator.new().generate(rng)
	ExplorationBuilder.new().build(self, exploration_layout)
	(get_node("NavigationGrid") as NavigationGrid).rebuild_ground()
	var player := get_node("Hub/Player") as PlayerActor
	player.global_position = ExplorationGenerator.HUB_SPAWN
	generation_revision += 1
	_update_camera()

func _update_camera() -> void:
	var camera := get_node("Camera2D") as Camera2D
	camera.global_position = (get_node("Hub/Player") as PlayerActor).global_position
	camera.force_update_scroll()

func _clear_generated_session_state() -> void:
	var player := get_node("Hub/Player") as PlayerActor
	player.cancel_pointer_input()
	player.stop_movement()
	(get_node("InteractionController") as InteractionController).cancel_interaction()
	var combat := get_node("CombatController") as CombatController
	combat.target = null
	var vendor_window := get_node("VendorWindow") as VendorWindow
	vendor_window.hide()
	for node: Node in get_tree().get_nodes_in_group("world_transients"):
		if is_ancestor_of(node):
			node.free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("use_enhanced_health_potion", false):
		use_health_potion("enhanced_health_potion")
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("use_health_potion", false):
		use_health_potion()
		get_viewport().set_input_as_handled()
		return
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
	game_clock.active = true
	_time_hud.visible = true
	game_clock.set_trading_open((get_node("VendorWindow") as VendorWindow).visible)

func save_manual(slot_id: String) -> bool:
	var manager := get_node_or_null("/root/SaveManager")
	return manager != null and manager.call("save_manual", slot_id, _build_save_payload())

func save_important_milestone() -> bool:
	return _save_autoslot()

func save_quest_completion() -> bool:
	return _save_autoslot()

func save_level_up() -> bool:
	return _save_autoslot()

func use_health_potion(item_id: String = "health_potion") -> bool:
	if not _session_active or _inventory == null or get_tree().paused:
		return false
	var player := get_node_or_null("Hub/Player") as PlayerActor
	if player == null or player.current_health >= player.max_health:
		return false
	var item_index := _inventory.find_item_index_by_id(item_id)
	if item_index < 0:
		return false
	var potion := _inventory.collected_items[item_index]
	if potion.health_restore <= 0:
		return false
	var consumed := _inventory.remove_item_at(item_index, 1)
	if consumed == null:
		return false
	player.heal(consumed.health_restore)
	return true

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
		"game_time": game_clock.snapshot(),
		"limited_vendor": (get_node("LimitedVendorService") as VendorService).stock_snapshot(),
	}

func _restore_pending_game() -> void:
	var manager := get_node_or_null("/root/SaveManager")
	if manager == null:
		return
	var pending_data: Dictionary = manager.get("pending_game_data")
	if pending_data.is_empty():
		return
	var payload := pending_data
	if payload.has("game_time") and not GameClock.valid_snapshot(payload["game_time"]):
		return
	var limited := get_node("LimitedVendorService") as VendorService
	if payload.has("limited_vendor") and not VendorService.valid_stock_snapshot(payload.limited_vendor, limited.definition):
		return
	if _progression == null or _inventory == null:
		return
	if not _inventory.restore_items(payload.get("items", []), payload.get("positions", []), payload.get("counts", [])):
		return
	_progression.gold = maxi(0, int(payload.get("gold", 0)))
	if payload.has("game_time"):
		game_clock.restore(payload["game_time"])
	else:
		game_clock.reset()
	if payload.has("limited_vendor"):
		limited.restore_stock(payload.limited_vendor)
	else:
		limited.configure(preload("res://data/vendors/limited_vendor.tres"), _inventory, _progression)
		limited.current_day = game_clock.day if game_clock.minute >= 360.0 else maxi(0, game_clock.day - 1)
	if procedural_generation_enabled:
		regenerate_exploration()
	else:
		_reset_cache_world_state()
	game_clock.set_trading_open(false)
	var player := get_node_or_null("Hub/Player") as PlayerActor
	if player != null:
		player.restore_full_health()
	manager.call("clear_pending_game_data")

func _reset_cache_world_state() -> void:
	var interactions := get_node_or_null("InteractionController") as InteractionController
	if interactions != null:
		interactions.cancel_interaction()
	var player := get_node_or_null("Hub/Player") as PlayerActor
	if player != null:
		player.cancel_pointer_input()
		player.stop_movement()
	for node: Node in get_tree().get_nodes_in_group("gold_pickups"):
		if is_ancestor_of(node):
			node.queue_free()
	for node: Node in get_tree().get_nodes_in_group("map_caches"):
		if is_ancestor_of(node):
			(node as MapCache).reset_cache()
