extends RefCounted
class_name BuybackEntry

var item: ItemDefinition
var repurchase_price: int

func _init(item_definition: ItemDefinition, price: int) -> void:
	item = item_definition
	repurchase_price = maxi(0, price)
