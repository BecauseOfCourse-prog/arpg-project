extends Resource
class_name VendorOffer

@export var item: ItemDefinition
@export_range(0, 1000000, 1) var purchase_price: int = 0
@export_range(0, 1000000, 1) var stock_quantity: int = 0
