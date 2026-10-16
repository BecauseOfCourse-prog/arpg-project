extends CanvasLayer
class_name DebugTimePanel

var clock: GameClock
var _panel: PanelContainer
var _readout: Label
var _hour: SpinBox
var _minute: SpinBox
var _freeze: CheckButton

func configure(game_clock: GameClock) -> void:
	clock = game_clock
	layer = 4
	visible = false
	var toggle := Button.new()
	toggle.text = "Время · F8"
	toggle.position = Vector2(650, 12)
	toggle.pressed.connect(toggle_panel)
	add_child(toggle)
	_panel = PanelContainer.new()
	_panel.position = Vector2(380, 65)
	_panel.custom_minimum_size = Vector2(440, 0)
	_panel.hide()
	add_child(_panel)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	_panel.add_child(column)
	_readout = Label.new()
	column.add_child(_readout)
	var selection := HBoxContainer.new()
	column.add_child(selection)
	_hour = _number_field(selection, 23)
	var colon := Label.new()
	colon.text = ":"
	selection.add_child(colon)
	_minute = _number_field(selection, 59)
	_button(selection, "Перейти", func() -> void: jump_to(int(_hour.value), int(_minute.value)))
	var presets := HBoxContainer.new()
	column.add_child(presets)
	for entry: Array in [["Утро", 6], ["День", 12], ["Вечер", 18], ["Ночь", 22]]:
		_button(presets, entry[0], jump_to.bind(entry[1], 0))
	var steps := HBoxContainer.new()
	column.add_child(steps)
	_button(steps, "+1 час", advance_minutes.bind(60.0))
	_button(steps, "+1 сутки", advance_minutes.bind(1440.0))
	_freeze = CheckButton.new()
	_freeze.text = "Остановить часы"
	_freeze.toggled.connect(func(value: bool) -> void: clock.debug_frozen = value)
	column.add_child(_freeze)
	var hint := Label.new()
	hint.text = "Переход вперёд к выбранному времени."
	column.add_child(hint)
	_button(column, "Закрыть · F8", toggle_panel)
	clock.time_changed.connect(_update_readout)
	_update_readout()

func _number_field(parent: Control, maximum: int) -> SpinBox:
	var field := SpinBox.new()
	field.min_value = 0
	field.max_value = maximum
	field.step = 1
	field.custom_minimum_size.x = 90
	parent.add_child(field)
	return field

func _button(parent: Control, title: String, action: Callable) -> void:
	var button := Button.new()
	button.text = title
	button.pressed.connect(action)
	parent.add_child(button)

func _input(event: InputEvent) -> void:
	if visible and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F8:
		toggle_panel()
		get_viewport().set_input_as_handled()

func toggle_panel() -> void:
	if not visible or get_tree().paused:
		return
	_panel.visible = not _panel.visible
	if _panel.visible:
		_hour.value = int(clock.minute) / 60
		_minute.value = int(clock.minute) % 60
		_freeze.set_pressed_no_signal(clock.debug_frozen)

func jump_to(hour: int, minute: int) -> void:
	if not visible or get_tree().paused or hour < 0 or hour > 23 or minute < 0 or minute > 59:
		return
	var target := float(hour * 60 + minute)
	if int(clock.minute) == int(target):
		return
	advance_minutes(fposmod(target - clock.minute, GameClock.DAY_MINUTES))

func advance_minutes(amount: float) -> void:
	if visible and not get_tree().paused:
		clock.advance(amount)

func reset_controls() -> void:
	clock.debug_frozen = false
	_freeze.set_pressed_no_signal(false)
	_panel.hide()

func _update_readout() -> void:
	_readout.text = "Тест времени · День %d · %02d:%02d" % [clock.day, int(clock.minute) / 60, int(clock.minute) % 60]
