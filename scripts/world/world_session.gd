extends Node2D

func _ready() -> void:
	var player := get_node_or_null("Hub/Player") as PlayerActor
	var inventory := get_node_or_null("Inventory") as InventoryController
	var progression := get_node_or_null("PlayerProgression") as PlayerProgression
	var service := get_node_or_null("VendorService") as VendorService
	var vendor := get_node_or_null("Hub/Vendor") as VendorInteractable
	var window := get_node_or_null("VendorWindow") as VendorWindow
	if player != null and progression != null:
		progression.initialize_from_definition(player.definition)
	if service != null and inventory != null and progression != null:
		service.configure(preload("res://data/vendors/hub_vendor.tres"), inventory, progression)
	if vendor != null and service != null and window != null:
		window.inventory = inventory
		window.progression = progression
		vendor.activated.connect(window.open_vendor.bind(service))
		if inventory != null:
			inventory.item_clicked.connect(window.sell_inventory_item)
