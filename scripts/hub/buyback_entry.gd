extends RefCounted
class_name BuybackEntry

var item: ItemDefinition
var unit_price: int
var quantity: int = 1

var repurchase_price: int:
	get:
		return unit_price * quantity

func _init(item_definition: ItemDefinition, price: int, item_quantity: int = 1) -> void:
	item = item_definition
	unit_price = maxi(0, price)
	quantity = maxi(1, item_quantity)
