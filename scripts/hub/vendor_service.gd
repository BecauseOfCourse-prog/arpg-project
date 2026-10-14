extends Node
class_name VendorService

signal transaction_completed(message: String)
signal transaction_rejected(reason: String)
signal buyback_changed

var inventory: InventoryController
var progression: PlayerProgression
var definition: VendorDefinition
var current_day: int = 0
var _remaining_stock: Array[int] = []
var buyback_entries: Array[BuybackEntry] = []

func configure(vendor_definition: VendorDefinition, inventory_controller: InventoryController, player_progression: PlayerProgression) -> void:
	definition = vendor_definition
	inventory = inventory_controller
	progression = player_progression
	_reset_stock()

func buy(offer_index: int) -> bool:
	if not _is_configured() or offer_index < 0 or offer_index >= definition.offers.size():
		return _reject("Товар недоступен.")
	var offer := definition.offers[offer_index]
	if offer == null or offer.item == null or offer.purchase_price < 0:
		return _reject("Товар недоступен.")
	if definition.stock_mode == VendorDefinition.StockMode.DAILY_LIMITED and _remaining_stock[offer_index] <= 0:
		return _reject("Товар закончился.")
	if not progression.can_spend(offer.purchase_price):
		return _reject("Недостаточно золота.")
	if not inventory.can_add_item(offer.item):
		return _reject("Недостаточно места в инвентаре.")
	# Validate every operation before mutating either owner of transaction state.
	if not progression.spend(offer.purchase_price):
		return _reject("Недостаточно золота.")
	if not inventory.add_item(offer.item):
		progression.add_gold(offer.purchase_price)
		return _reject("Недостаточно места в инвентаре.")
	if definition.stock_mode == VendorDefinition.StockMode.DAILY_LIMITED:
		_remaining_stock[offer_index] -= 1
	transaction_completed.emit("Покупка: %s" % offer.item.display_name)
	return true

func sell(inventory_index: int) -> bool:
	if not _is_configured() or inventory_index < 0 or inventory_index >= inventory.collected_items.size():
		return _reject("Предмет недоступен.")
	var item := inventory.collected_items[inventory_index]
	if item == null or item.purchase_price <= 0:
		return _reject("Этот предмет нельзя продать.")
	# Equipment is only sellable after being unequipped into inventory. The
	# current prototype has no equipment slots, so inventory items are unequipped.
	var category := item.category
	if category != ItemDefinition.ItemCategory.EQUIPMENT and category != ItemDefinition.ItemCategory.CONSUMABLE:
		return _reject("Этот предмет нельзя продать.")
	if not _can_add_buyback_item(item):
		return _reject("В списке выкупа нет места.")
	var proceeds := floori(float(item.purchase_price) * 0.5)
	var removed := inventory.remove_item_at(inventory_index)
	if removed == null:
		return _reject("Предмет недоступен.")
	progression.add_gold(proceeds)
	buyback_entries.append(BuybackEntry.new(item, proceeds))
	buyback_changed.emit()
	transaction_completed.emit("Продано: %s (+%d золота)" % [item.display_name, proceeds])
	return true

func buyback(entry_index: int) -> bool:
	if not _is_configured() or entry_index < 0 or entry_index >= buyback_entries.size():
		return _reject("Предмет для выкупа недоступен.")
	var entry := buyback_entries[entry_index]
	if entry == null or entry.item == null:
		return _reject("Предмет для выкупа недоступен.")
	if not progression.can_spend(entry.repurchase_price):
		return _reject("Недостаточно золота для выкупа.")
	if not inventory.can_add_item(entry.item):
		return _reject("Недостаточно места в инвентаре.")
	if not progression.spend(entry.repurchase_price):
		return _reject("Недостаточно золота для выкупа.")
	if not inventory.add_item(entry.item):
		progression.add_gold(entry.repurchase_price)
		return _reject("Недостаточно места в инвентаре.")
	buyback_entries.remove_at(entry_index)
	buyback_changed.emit()
	transaction_completed.emit("Выкуплено: %s" % entry.item.display_name)
	return true

func advance_day(new_day: int) -> void:
	if definition == null or definition.stock_mode != VendorDefinition.StockMode.DAILY_LIMITED or new_day <= current_day:
		return
	current_day = new_day
	_reset_stock()

func remaining_stock(offer_index: int) -> int:
	if not _is_configured() or offer_index < 0 or offer_index >= _remaining_stock.size():
		return 0
	return _remaining_stock[offer_index]

func _is_configured() -> bool:
	return definition != null and inventory != null and progression != null

func _reset_stock() -> void:
	_remaining_stock.clear()
	if definition == null:
		return
	for offer: VendorOffer in definition.offers:
		_remaining_stock.append(maxi(0, offer.stock_quantity) if offer != null else 0)

func _can_add_buyback_item(item: ItemDefinition) -> bool:
	const GRID_WIDTH := 10
	const GRID_HEIGHT := 10
	var occupied: Array[Array] = []
	for y in range(GRID_HEIGHT):
		var row: Array[bool] = []
		row.resize(GRID_WIDTH)
		row.fill(false)
		occupied.append(row)
	var items: Array[ItemDefinition] = []
	for entry: BuybackEntry in buyback_entries:
		if entry != null and entry.item != null:
			items.append(entry.item)
	items.append(item)
	for definition_item: ItemDefinition in items:
		var width := clampi(definition_item.inventory_width, 1, GRID_WIDTH)
		var height := clampi(definition_item.inventory_height, 1, GRID_HEIGHT)
		var found := Vector2i(-1, -1)
		for y in range(GRID_HEIGHT - height + 1):
			for x in range(GRID_WIDTH - width + 1):
				var fits := true
				for item_y in range(y, y + height):
					for item_x in range(x, x + width):
						if occupied[item_y][item_x]:
							fits = false
				if fits and found.x == -1:
					found = Vector2i(x, y)
		if found.x == -1:
			return false
		for item_y in range(found.y, found.y + height):
			for item_x in range(found.x, found.x + width):
				occupied[item_y][item_x] = true
	return true

func _reject(reason: String) -> bool:
	transaction_rejected.emit(reason)
	return false
