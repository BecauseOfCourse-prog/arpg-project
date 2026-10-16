extends Node
class_name GameClock

signal time_changed
signal vendor_refresh_due(trading_day: int)

const DAY_MINUTES := 1440.0
const MAX_DAY := 100_000
var day := 1
var minute := 480.0
var active := false
var debug_frozen := false
var pending_vendor_day := -1
var trading_open := false

func _process(delta: float) -> void:
	if active and not debug_frozen:
		advance(delta)

func reset() -> void:
	day = 1
	minute = 480.0
	pending_vendor_day = -1
	time_changed.emit()

func advance(real_seconds: float) -> void:
	if real_seconds <= 0.0 or not is_finite(real_seconds):
		return
	var previous := (day - 1) * DAY_MINUTES + minute
	# Stop at the last millisecond of the supported calendar rather than
	# generating day 100001 and a save that our validator would reject.
	var total := minf(previous + real_seconds, MAX_DAY * DAY_MINUTES - 0.001)
	day = int(floor(total / DAY_MINUTES)) + 1
	minute = fposmod(total, DAY_MINUTES)
	var first_boundary := int(floor((previous - 360.0) / DAY_MINUTES)) + 1
	var last_boundary := int(floor((total - 360.0) / DAY_MINUTES))
	for boundary in range(first_boundary, last_boundary + 1):
		if trading_open:
			pending_vendor_day = boundary + 1
		else:
			vendor_refresh_due.emit(boundary + 1)
	time_changed.emit()

func set_trading_open(value: bool) -> void:
	trading_open = value
	if not value and pending_vendor_day >= 0:
		var due := pending_vendor_day
		pending_vendor_day = -1
		vendor_refresh_due.emit(due)

func period() -> String:
	if minute < 360.0 or minute >= 1320.0:
		return "Night"
	if minute < 600.0:
		return "Morning"
	if minute < 1080.0:
		return "Day"
	return "Evening"

func lighting() -> Color:
	var points := [0.0, 360.0, 600.0, 1080.0, 1320.0, 1440.0]
	var colors := [Color(0.48, 0.53, 0.68), Color(0.72, 0.70, 0.72), Color.WHITE, Color(0.95, 0.83, 0.72), Color(0.48, 0.53, 0.68), Color(0.48, 0.53, 0.68)]
	for index in range(points.size() - 1):
		if minute < points[index + 1]:
			var weight: float = smoothstep(points[index], points[index + 1], minute)
			return colors[index].lerp(colors[index + 1], weight)
	return colors[0]

func snapshot() -> Dictionary:
	return {"day": day, "minute": minute, "pending_vendor_day": pending_vendor_day}

static func valid_snapshot(data: Variant) -> bool:
	if not data is Dictionary:
		return false
	for key: String in ["day", "minute", "pending_vendor_day"]:
		if not data.get(key) is int and not data.get(key) is float:
			return false
		if not is_finite(float(data[key])):
			return false
	return float(data.day) == floor(float(data.day)) and data.day >= 1 and data.day <= MAX_DAY and data.minute >= 0 and data.minute < DAY_MINUTES and float(data.pending_vendor_day) == floor(float(data.pending_vendor_day)) and (data.pending_vendor_day == -1 or (data.pending_vendor_day >= 1 and data.pending_vendor_day <= data.day))

func restore(data: Dictionary) -> bool:
	if not valid_snapshot(data):
		return false
	day = int(data.day)
	minute = float(data.minute)
	pending_vendor_day = int(data.pending_vendor_day)
	time_changed.emit()
	return true
