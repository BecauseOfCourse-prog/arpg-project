extends Resource
class_name ItemDefinition

enum ItemCategory { EQUIPMENT, CONSUMABLE }

@export var definition_id: String = ""
@export var display_name: String = ""
@export var rarity: String = ""
@export var affix_text: String = ""
@export var category: ItemCategory = ItemCategory.EQUIPMENT
@export_range(0, 1000000, 1) var purchase_price: int = 0
@export_range(1, 10, 1) var inventory_width: int = 1
@export_range(1, 4, 1) var inventory_height: int = 1
