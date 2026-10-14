extends Area2D
class_name VendorInteractable

signal activated

func _ready() -> void:
	input_pickable = true
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_index: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		activated.emit()
		get_viewport().set_input_as_handled()
