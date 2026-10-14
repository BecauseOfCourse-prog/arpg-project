extends Node
class_name PlayerProgression

var gold: int = 0

func initialize_from_definition(definition: PlayerDefinition) -> void:
	if definition != null:
		gold = maxi(0, definition.starting_gold)

func can_spend(amount: int) -> bool:
	return amount >= 0 and gold >= amount

func spend(amount: int) -> bool:
	if not can_spend(amount):
		return false
	gold -= amount
	return true

func add_gold(amount: int) -> void:
	if amount > 0:
		gold += amount
