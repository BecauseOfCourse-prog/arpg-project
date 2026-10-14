extends Control
class_name VendorGridView

signal item_clicked(item_index: int)

const COLUMNS := 10
const ROWS := 10
const SLOT_SIZE := Vector2(32, 32)
const GAP := 2.0

var _items: Array[ItemDefinition] = []
var _counts: Array[int] = []
var _prices: Array[int] = []
var _stock_labels: Array[String] = []
var _item_positions: Array[Vector2i] = []

func _ready() -> void:
	custom_minimum_size = Vector2(COLUMNS * SLOT_SIZE.x + (COLUMNS - 1) * GAP, ROWS * SLOT_SIZE.y + (ROWS - 1) * GAP)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_rebuild_positions()

func show_offers(offers: Array[VendorOffer], stock_labels: Array[String]) -> void:
	_items.clear()
	_counts.clear()
	_prices.clear()
	_stock_labels.clear()
	for index in range(offers.size()):
		var offer := offers[index]
		if offer == null:
			_items.append(null)
			_counts.append(0)
			_prices.append(0)
			_stock_labels.append("")
			continue
		_items.append(offer.item)
		_counts.append(1)
		_prices.append(offer.purchase_price)
		_stock_labels.append(stock_labels[index] if index < stock_labels.size() else "")
	_rebuild_positions()
	queue_redraw()

func show_buyback(entries: Array[BuybackEntry]) -> void:
	_items.clear()
	_counts.clear()
	_prices.clear()
	_stock_labels.clear()
	for entry: BuybackEntry in entries:
		_items.append(entry.item if entry != null else null)
		_counts.append(entry.quantity if entry != null else 0)
		_prices.append(entry.repurchase_price if entry != null else 0)
		_stock_labels.append("Buy back")
	_rebuild_positions()
	queue_redraw()

func refresh() -> void:
	_rebuild_positions()
	queue_redraw()

func _draw() -> void:
	for y in range(ROWS):
		for x in range(COLUMNS):
			var rect := Rect2(Vector2(x, y) * (SLOT_SIZE + Vector2(GAP, GAP)), SLOT_SIZE)
			draw_rect(rect, Color(0.09, 0.1, 0.12, 1), true)
			draw_rect(rect, Color(0.48, 0.5, 0.53, 1), false, 1.0)
	for index in range(mini(_items.size(), _item_positions.size())):
		var item := _items[index]
		if item == null or _item_positions[index].x < 0:
			continue
		var origin := _item_positions[index]
		var width := clampi(item.inventory_width, 1, COLUMNS)
		var height := clampi(item.inventory_height, 1, ROWS)
		var top_left := Vector2(origin) * (SLOT_SIZE + Vector2(GAP, GAP))
		var size := Vector2(width, height) * SLOT_SIZE + Vector2((width - 1) * GAP, (height - 1) * GAP)
		var rect := Rect2(top_left, size)
		draw_rect(rect, Color(0.34, 0.3, 0.2, 1), true)
		draw_rect(rect, Color(0.82, 0.68, 0.39, 1), false, 1.0)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(4, 15), item.display_name.left(12), HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 8, 11, Color.WHITE)
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(4, 28), "%d gold" % _prices[index], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 8, 10, Color(1, 0.88, 0.55, 1))
		if _counts[index] > 1:
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(rect.size.x - 20, 14), "×%d" % _counts[index], HORIZONTAL_ALIGNMENT_RIGHT, 18, 9, Color(1, 0.9, 0.55, 1))
		if not _stock_labels[index].is_empty():
			draw_string(ThemeDB.fallback_font, rect.position + Vector2(4, 40), _stock_labels[index], HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 8, 9, Color.WHITE)

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT or not event.pressed:
		return
	var pitch := SLOT_SIZE + Vector2(GAP, GAP)
	var column := floori(event.position.x / pitch.x)
	var row := floori(event.position.y / pitch.y)
	if column < 0 or column >= COLUMNS or row < 0 or row >= ROWS:
		return
	if fmod(event.position.x, pitch.x) > SLOT_SIZE.x or fmod(event.position.y, pitch.y) > SLOT_SIZE.y:
		return
	for index in range(mini(_items.size(), _item_positions.size())):
		var item := _items[index]
		if item == null or _item_positions[index].x < 0:
			continue
		var origin := _item_positions[index]
		var width := clampi(item.inventory_width, 1, COLUMNS)
		var height := clampi(item.inventory_height, 1, ROWS)
		if column >= origin.x and column < origin.x + width and row >= origin.y and row < origin.y + height:
			item_clicked.emit(index)
			accept_event()
			return

func _rebuild_positions() -> void:
	_item_positions.clear()
	var occupied: Array[Array] = []
	for y in range(ROWS):
		var row: Array[bool] = []
		row.resize(COLUMNS)
		row.fill(false)
		occupied.append(row)
	for item: ItemDefinition in _items:
		if item == null:
			_item_positions.append(Vector2i(-1, -1))
			continue
		var width := clampi(item.inventory_width, 1, COLUMNS)
		var height := clampi(item.inventory_height, 1, ROWS)
		var found := Vector2i(-1, -1)
		for y in range(ROWS - height + 1):
			for x in range(COLUMNS - width + 1):
				var fits := true
				for item_y in range(y, y + height):
					for item_x in range(x, x + width):
						if occupied[item_y][item_x]:
							fits = false
				if fits and found.x == -1:
					found = Vector2i(x, y)
		if found.x >= 0:
			for item_y in range(found.y, found.y + height):
				for item_x in range(found.x, found.x + width):
					occupied[item_y][item_x] = true
		_item_positions.append(found)
