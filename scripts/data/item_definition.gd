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
@export var stackable: bool = false
@export_range(1, 12, 1) var max_stack_size: int = 12
@export_range(0, 1000000, 1) var health_restore: int = 0

func stack_limit() -> int:
	return clampi(max_stack_size, 1, 12)
