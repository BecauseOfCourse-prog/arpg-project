extends CanvasLayer
class_name PlayerHUD

@export var player_path: NodePath = NodePath("../Hub/Player")

var _player: PlayerActor
var _health_bar: ProgressBar

func _ready() -> void:
	_player = get_node_or_null(player_path) as PlayerActor
	_build_health_bar()
	if _player != null:
		_player.health_changed.connect(_on_health_changed)
		_on_health_changed(_player.current_health, _player.max_health)

func _build_health_bar() -> void:
	var overlay := Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(overlay)
	var title := Label.new()
	title.text = "HEALTH"
	title.position = Vector2(16, 246)
	title.size = Vector2(346, 18)
	overlay.add_child(title)
	_health_bar = ProgressBar.new()
	_health_bar.position = Vector2(16, 264)
	_health_bar.size = Vector2(346, 18)
	_health_bar.show_percentage = false
	_health_bar.min_value = 0.0
	overlay.add_child(_health_bar)

func _on_health_changed(current_health: int, maximum_health: int) -> void:
	if _health_bar == null:
		return
	_health_bar.max_value = maximum_health
	_health_bar.value = current_health
