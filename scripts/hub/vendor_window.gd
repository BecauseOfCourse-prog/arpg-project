extends CanvasLayer
class_name VendorWindow

var service: VendorService
var inventory: InventoryController
var progression: PlayerProgression
var _panel: PanelContainer
var _status: Label
var _offer_grid: Control
var _showing_buyback := false
var _title: Label

func _ready() -> void:
	visible = false
	_build_ui()

func open_vendor(vendor_service: VendorService) -> void:
	service = vendor_service
	_title.text = service.definition.vendor_name
	if not service.transaction_rejected.is_connected(_on_transaction_rejected):
		service.transaction_rejected.connect(_on_transaction_rejected)
	if not service.transaction_completed.is_connected(_on_transaction_completed):
		service.transaction_completed.connect(_on_transaction_completed)
	visible = true
	_showing_buyback = false
	_status.text = "Золото: %d" % progression.gold if progression != null else ""
	_refresh()

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(870, 16)
	_panel.custom_minimum_size = Vector2(380, 430)
	add_child(_panel)
	var column := VBoxContainer.new()
	_panel.add_child(column)
	var header := HBoxContainer.new()
	column.add_child(header)
	var title := Label.new()
	_title = title
	title.text = "Торговец"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var close := Button.new()
	close.text = "Закрыть"
	close.pressed.connect(func() -> void: visible = false)
	header.add_child(close)
	_status = Label.new()
	column.add_child(_status)
	var tabs := HBoxContainer.new()
	column.add_child(tabs)
	var buy_tab := Button.new()
	buy_tab.text = "Покупка"
	buy_tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buy_tab.pressed.connect(_show_buy_tab)
	tabs.add_child(buy_tab)
	var buyback_tab := Button.new()
	buyback_tab.text = "Выкуп"
	buyback_tab.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buyback_tab.pressed.connect(_show_buyback_tab)
	tabs.add_child(buyback_tab)
	_offer_grid = load("res://scripts/hub/vendor_grid_view.gd").new()
	_offer_grid.connect("item_clicked", _on_grid_item_clicked)
	column.add_child(_offer_grid)

func _refresh() -> void:
	if _offer_grid == null or service == null:
		return
	if _showing_buyback:
		_offer_grid.call("show_buyback", service.buyback_entries)
	else:
		var stock_labels: Array[String] = []
		var visible_offers: Array[VendorOffer] = []
		if service.definition != null:
			for index in range(service.definition.offers.size()):
				var unlimited := service.definition.stock_mode == VendorDefinition.StockMode.FIXED_UNLIMITED
				# Preserve catalog indices while removing exhausted offers from drawing and hit testing.
				visible_offers.append(service.definition.offers[index] if unlimited or service.remaining_stock(index) > 0 else null)
				stock_labels.append("Без ограничений" if unlimited else "В наличии: %d" % service.remaining_stock(index))
			_offer_grid.call("show_offers", visible_offers, stock_labels)

func sell_inventory_item(index: int, sell_entire_stack: bool = false) -> void:
	if not visible or service == null:
		return
	service.sell(index, sell_entire_stack)
	_refresh()

func _on_grid_item_clicked(index: int) -> void:
	if service == null:
		return
	if _showing_buyback:
		service.buyback(index)
	else:
		service.buy(index)
	_refresh()

func _show_buy_tab() -> void:
	_showing_buyback = false
	_refresh()

func _show_buyback_tab() -> void:
	_showing_buyback = true
	_refresh()

func show_message(message: String) -> void:
	_status.text = message

func _on_transaction_rejected(reason: String) -> void:
	show_message(reason)

func _on_transaction_completed(message: String) -> void:
	show_message("%s · золото: %d" % [message, progression.gold] if progression != null else message)
