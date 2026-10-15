extends Control

const SLOT_IDS := ["manual_1", "manual_2", "manual_3", "autosave"]

var _manager: Node
var _world: Node2D
var _menu_layer: CanvasLayer
var _background: ColorRect
var _menu_contents: CenterContainer

func _ready() -> void:
	_manager = get_node("/root/SaveManager")
	_world = get_node("World") as Node2D
	_world.process_mode = Node.PROCESS_MODE_DISABLED
	_set_world_hud_visible(false)
	_build_interface()

func _build_interface() -> void:
	_menu_layer = CanvasLayer.new()
	_menu_layer.layer = 20
	add_child(_menu_layer)
	_background = ColorRect.new()
	_background.color = Color(0.08, 0.1, 0.12, 1)
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu_layer.add_child(_background)
	_menu_contents = CenterContainer.new()
	_menu_contents.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_menu_layer.add_child(_menu_contents)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(460, 500)
	_menu_contents.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	panel.add_child(content)
	var title := Label.new()
	title.text = "ARPG Prototype"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	var new_game := Button.new()
	new_game.text = "New Game"
	new_game.pressed.connect(_start_new_game)
	content.add_child(new_game)
	var load_title := Label.new()
	load_title.text = "Load Game"
	content.add_child(load_title)
	var any_available := false
	for slot_id: String in SLOT_IDS:
		var info: Dictionary = _manager.call("get_slot_info", slot_id)
		var label := Label.new()
		var slot_name := "Autosave" if slot_id == "autosave" else "Manual Slot %s" % slot_id.get_slice("_", 1)
		if info.get("status") == "available":
			label.text = "%s — %s" % [slot_name, info.get("saved_at", "Saved")]
			any_available = true
		else:
			var reason := "Empty" if info.get("status") == "empty" else "Unavailable: %s" % info.get("reason", "Invalid save")
			label.text = "%s — %s" % [slot_name, reason]
		content.add_child(label)
		var load_button := Button.new()
		load_button.text = "Load %s" % slot_name
		load_button.disabled = info.get("status") != "available"
		load_button.pressed.connect(_load_slot.bind(slot_id))
		content.add_child(load_button)
	var no_saves := Label.new()
	no_saves.text = "No saves available. Start a new game."
	no_saves.visible = not any_available
	content.add_child(no_saves)

func _start_new_game() -> void:
	_manager.call("clear_pending_game_data")
	_show_world()

func _load_slot(slot_id: String) -> void:
	if _manager.call("load_slot", slot_id):
		_world.call("_restore_pending_game")
		_show_world()

func _show_world() -> void:
	_menu_layer.hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_world.process_mode = Node.PROCESS_MODE_INHERIT
	_world.show()
	_set_world_hud_visible(true)
	_world.call("activate_session")

func _set_world_hud_visible(is_visible: bool) -> void:
	var inventory := _world.get_node_or_null("Inventory") as CanvasLayer
	if inventory != null:
		inventory.visible = is_visible
