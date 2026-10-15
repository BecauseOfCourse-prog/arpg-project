extends CanvasLayer
class_name PauseMenu

var _world_session: Node
var _status_label: Label
var _panel: PanelContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_world_session = get_parent()
	_build_interface()
	visible = false

func open_menu() -> void:
	visible = true
	get_tree().paused = true

func _build_interface() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color(0, 0, 0, 0.48)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(360, 330)
	_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	_panel.position = Vector2(-180, -165)
	add_child(_panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 8)
	_panel.add_child(content)
	var title := Label.new()
	title.text = "Pause"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(title)
	_status_label = Label.new()
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content.add_child(_status_label)
	for index in range(3):
		var slot_id := "manual_%d" % (index + 1)
		var button := Button.new()
		button.text = "Save to Slot %d" % (index + 1)
		button.pressed.connect(_save_to_slot.bind(slot_id))
		content.add_child(button)
	var resume_button := Button.new()
	resume_button.text = "Resume"
	resume_button.pressed.connect(_resume)
	content.add_child(resume_button)
	var menu_button := Button.new()
	menu_button.text = "Main Menu"
	menu_button.pressed.connect(_return_to_menu)
	content.add_child(menu_button)

func _save_to_slot(slot_id: String) -> void:
	var succeeded: bool = _world_session.call("save_manual", slot_id)
	_status_label.text = "Game saved." if succeeded else "Could not save the game."

func _resume() -> void:
	visible = false
	get_tree().paused = false

func _return_to_menu() -> void:
	# Leaving an active session through the menu is treated like an application exit.
	_world_session.call("save_important_milestone")
	_world_session.call("return_to_main_menu")
