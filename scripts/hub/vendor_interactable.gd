extends WorldInteractable
class_name VendorInteractable

signal activated

func _ready() -> void:
	super._ready()

func interact(_player: PlayerActor, _progression: PlayerProgression, _navigation: NavigationGrid) -> bool:
	activated.emit()
	return true
