extends GdUnitTestSuite

func test_world_wires_vendor_window_and_class_starting_gold() -> void:
	var scene := load("res://scenes/main/main.tscn") as PackedScene
	assert_object(scene).is_not_null()
	if scene == null:
		return
	var main := scene.instantiate()
	add_child(main)
	main.call("_start_new_game")
	await get_tree().process_frame
	var progression := main.get_node("World/PlayerProgression") as PlayerProgression
	var inventory := main.get_node("World/Inventory") as InventoryController
	var service := main.get_node("World/VendorService") as VendorService
	var vendor := main.get_node("World/Hub/Vendor") as VendorInteractable
	var window := main.get_node("World/VendorWindow") as VendorWindow
	assert_int(progression.gold).is_equal(100)
	assert_bool(service.definition != null).is_true()
	assert_int(service.definition.stock_mode).is_equal(VendorDefinition.StockMode.FIXED_UNLIMITED)
	assert_bool(window.visible).is_false()
	vendor.activated.emit()
	assert_bool(window.visible).is_true()
	window.call("_on_grid_item_clicked", 0)
	assert_int(progression.gold).is_equal(75)
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_int(inventory.item_counts[0]).is_equal(1)
	inventory.item_clicked.emit(0, false)
	assert_int(progression.gold).is_equal(87)
	assert_int(inventory.collected_items.size()).is_zero()
	assert_bool((window.get("_status") as Label).text.contains("Продано")).is_true()
	window.call("_show_buyback_tab")
	assert_bool(window.get("_showing_buyback")).is_true()
	window.call("_on_grid_item_clicked", 0)
	assert_int(progression.gold).is_equal(75)
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_int(inventory.item_counts[0]).is_equal(1)
	var bow := load("res://data/items/emberwood_bow.tres") as ItemDefinition
	var potion := load("res://data/items/health_potion.tres") as ItemDefinition
	assert_bool(bow.stackable).is_false()
	assert_bool(potion.stackable).is_true()
	assert_int(potion.max_stack_size).is_equal(12)
	main.queue_free()

func test_purchase_moves_gold_and_item_once() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	progression.gold = 100
	var item := _item("Potion", ItemDefinition.ItemCategory.CONSUMABLE, 20, Vector2i(1, 1))
	var service := _service(inventory, progression, item, 25, 2)
	assert_bool(service.buy(0)).is_true()
	assert_int(progression.gold).is_equal(75)
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_int(service.remaining_stock(0)).is_equal(1)
	inventory.free()
	progression.free()
	service.free()

func test_sale_returns_half_price_and_removes_item() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	var item := _item("Bow", ItemDefinition.ItemCategory.EQUIPMENT, 101, Vector2i(2, 3))
	assert_bool(inventory.add_item(item)).is_true()
	var service := VendorService.new()
	service.configure(VendorDefinition.new(), inventory, progression)
	assert_bool(service.sell(0)).is_true()
	assert_int(progression.gold).is_equal(50)
	assert_int(inventory.collected_items.size()).is_zero()
	inventory.free()
	progression.free()
	service.free()

func test_buyback_restores_sold_item_for_the_exact_sale_price() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	progression.gold = 20
	var item := _item("Bow", ItemDefinition.ItemCategory.EQUIPMENT, 100, Vector2i(2, 3))
	assert_bool(inventory.add_item(item)).is_true()
	var service := VendorService.new()
	service.configure(VendorDefinition.new(), inventory, progression)
	assert_bool(service.sell(0)).is_true()
	assert_int(progression.gold).is_equal(70)
	assert_int(service.buyback_entries.size()).is_equal(1)
	assert_int(service.buyback_entries[0].repurchase_price).is_equal(50)
	assert_bool(service.buyback(0)).is_true()
	assert_int(progression.gold).is_equal(20)
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_int(service.buyback_entries.size()).is_zero()
	inventory.free()
	progression.free()
	service.free()

func test_failed_buyback_keeps_item_and_gold_unchanged() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	progression.gold = 20
	var sold_item := _item("Bow", ItemDefinition.ItemCategory.EQUIPMENT, 100, Vector2i(2, 3))
	assert_bool(inventory.add_item(sold_item)).is_true()
	var service := VendorService.new()
	service.configure(VendorDefinition.new(), inventory, progression)
	assert_bool(service.sell(0)).is_true()
	var small_item := _item("Small", ItemDefinition.ItemCategory.CONSUMABLE, 1, Vector2i(1, 1))
	for _index in range(40):
		assert_bool(inventory.add_item(small_item)).is_true()
	var gold_before := progression.gold
	assert_bool(service.buyback(0)).is_false()
	assert_int(progression.gold).is_equal(gold_before)
	assert_int(inventory.collected_items.size()).is_equal(40)
	assert_int(service.buyback_entries.size()).is_equal(1)
	inventory.free()
	progression.free()
	service.free()

func test_sale_is_rejected_when_buyback_grid_is_full() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	var item := _item("Potion", ItemDefinition.ItemCategory.CONSUMABLE, 2, Vector2i(1, 1))
	var service := VendorService.new()
	service.configure(VendorDefinition.new(), inventory, progression)
	for _index in range(100):
		assert_bool(inventory.add_item(item)).is_true()
		assert_bool(service.sell(0)).is_true()
	assert_int(service.buyback_entries.size()).is_equal(100)
	assert_bool(inventory.add_item(item)).is_true()
	assert_bool(service.sell(0)).is_false()
	assert_int(progression.gold).is_equal(100)
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_int(service.buyback_entries.size()).is_equal(100)
	inventory.free()
	progression.free()
	service.free()

func test_failed_purchase_leaves_gold_inventory_and_stock_unchanged() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	progression.gold = 100
	var small_item := _item("Small", ItemDefinition.ItemCategory.CONSUMABLE, 1, Vector2i(1, 1))
	for _index in range(40):
		assert_bool(inventory.add_item(small_item)).is_true()
	var large_item := _item("Large", ItemDefinition.ItemCategory.EQUIPMENT, 10, Vector2i(2, 1))
	var service := _service(inventory, progression, large_item, 20, 2)
	var rejection := [""]
	service.transaction_rejected.connect(func(reason: String) -> void: rejection[0] = reason)
	assert_bool(service.buy(0)).is_false()
	assert_bool(not rejection[0].is_empty()).is_true()
	assert_int(progression.gold).is_equal(100)
	assert_int(inventory.collected_items.size()).is_equal(40)
	assert_int(service.remaining_stock(0)).is_equal(2)
	inventory.free()
	progression.free()
	service.free()

func test_purchase_with_insufficient_gold_does_not_change_state() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	progression.gold = 10
	var item := _item("Potion", ItemDefinition.ItemCategory.CONSUMABLE, 20, Vector2i(1, 1))
	var service := _service(inventory, progression, item, 25, 1)
	assert_bool(service.buy(0)).is_false()
	assert_int(progression.gold).is_equal(10)
	assert_int(inventory.collected_items.size()).is_zero()
	assert_int(service.remaining_stock(0)).is_equal(1)
	inventory.free()
	progression.free()
	service.free()

func test_daily_stock_refreshes_only_when_day_advances() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	progression.gold = 100
	var item := _item("Potion", ItemDefinition.ItemCategory.CONSUMABLE, 20, Vector2i(1, 1))
	var service := _service(inventory, progression, item, 25, 1)
	assert_bool(service.buy(0)).is_true()
	assert_bool(service.buy(0)).is_false()
	service.advance_day(1)
	assert_int(service.remaining_stock(0)).is_equal(1)
	inventory.free()
	progression.free()
	service.free()

func test_fixed_stock_offer_has_unlimited_quantity() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	progression.gold = 100
	var item := _item("Potion", ItemDefinition.ItemCategory.CONSUMABLE, 20, Vector2i(1, 1))
	var offer := VendorOffer.new()
	offer.item = item
	offer.purchase_price = 25
	var definition := VendorDefinition.new()
	definition.stock_mode = VendorDefinition.StockMode.FIXED_UNLIMITED
	definition.offers = [offer]
	var service := VendorService.new()
	service.configure(definition, inventory, progression)
	assert_bool(service.buy(0)).is_true()
	assert_bool(service.buy(0)).is_true()
	assert_int(inventory.collected_items.size()).is_equal(2)
	assert_int(progression.gold).is_equal(50)
	inventory.free()
	progression.free()
	service.free()

func test_stackable_consumables_share_a_slot_up_to_twelve() -> void:
	var inventory := InventoryController.new()
	var potion := _item("Potion", ItemDefinition.ItemCategory.CONSUMABLE, 25, Vector2i(1, 1), true)
	assert_bool(inventory.add_item(potion, 12)).is_true()
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_int(inventory.item_counts[0]).is_equal(12)
	assert_bool(inventory.can_add_item(potion)).is_true()
	assert_bool(inventory.add_item(potion)).is_true()
	assert_int(inventory.collected_items.size()).is_equal(2)
	assert_int(inventory.item_counts[0]).is_equal(12)
	assert_int(inventory.item_counts[1]).is_equal(1)
	assert_bool(inventory.item_positions[0] != inventory.item_positions[1]).is_true()
	inventory.free()

func test_nonstackable_equipment_uses_one_slot_per_copy() -> void:
	var inventory := InventoryController.new()
	var bow := _item("Bow", ItemDefinition.ItemCategory.EQUIPMENT, 100, Vector2i(2, 3))
	assert_bool(inventory.add_item(bow)).is_true()
	assert_bool(inventory.add_item(bow)).is_true()
	assert_int(inventory.collected_items.size()).is_equal(2)
	assert_int(inventory.item_counts[0]).is_equal(1)
	assert_int(inventory.item_counts[1]).is_equal(1)
	assert_bool(inventory.item_positions[0] != inventory.item_positions[1]).is_true()
	inventory.free()

func test_sale_click_sells_one_and_shift_sale_sells_the_rest_of_stack() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	var potion := _item("Potion", ItemDefinition.ItemCategory.CONSUMABLE, 25, Vector2i(1, 1), true)
	var service := VendorService.new()
	service.configure(VendorDefinition.new(), inventory, progression)
	assert_bool(inventory.add_item(potion, 3)).is_true()
	assert_bool(service.sell(0)).is_true()
	assert_int(inventory.item_counts[0]).is_equal(2)
	assert_int(progression.gold).is_equal(12)
	assert_int(service.buyback_entries[0].quantity).is_equal(1)
	assert_bool(service.sell(0, true)).is_true()
	assert_int(inventory.collected_items.size()).is_zero()
	assert_int(progression.gold).is_equal(36)
	assert_int(service.buyback_entries.size()).is_equal(1)
	assert_int(service.buyback_entries[0].quantity).is_equal(3)
	assert_int(service.buyback_entries[0].repurchase_price).is_equal(36)
	inventory.free()
	progression.free()
	service.free()

func test_buyback_restores_full_stack_quantity() -> void:
	var inventory := InventoryController.new()
	var progression := PlayerProgression.new()
	var potion := _item("Potion", ItemDefinition.ItemCategory.CONSUMABLE, 25, Vector2i(1, 1), true)
	var service := VendorService.new()
	service.configure(VendorDefinition.new(), inventory, progression)
	assert_bool(inventory.add_item(potion, 12)).is_true()
	assert_bool(service.sell(0, true)).is_true()
	assert_bool(service.buyback(0)).is_true()
	assert_int(inventory.collected_items.size()).is_equal(1)
	assert_int(inventory.item_counts[0]).is_equal(12)
	inventory.free()
	progression.free()
	service.free()

func _item(name: String, category: ItemDefinition.ItemCategory, price: int, size: Vector2i, stackable: bool = false) -> ItemDefinition:
	var item := ItemDefinition.new()
	item.display_name = name
	item.category = category
	item.purchase_price = price
	item.inventory_width = size.x
	item.inventory_height = size.y
	item.stackable = stackable
	item.max_stack_size = 12
	return item

func _service(inventory: InventoryController, progression: PlayerProgression, item: ItemDefinition, price: int, quantity: int) -> VendorService:
	var offer := VendorOffer.new()
	offer.item = item
	offer.purchase_price = price
	offer.stock_quantity = quantity
	var definition := VendorDefinition.new()
	definition.stock_mode = VendorDefinition.StockMode.DAILY_LIMITED
	definition.offers = [offer]
	var service := VendorService.new()
	service.configure(definition, inventory, progression)
	return service
