extends WorldInteractable
class_name GoldPickup

var amount: int = 1
var collected := false

func _ready() -> void:
	super._ready()
	add_to_group("gold_pickups")
	add_to_group("world_transients")
	var label := get_node_or_null("Amount") as Label
	if label != null:
		label.text = "%d gold" % amount

func interact(_player: PlayerActor, progression: PlayerProgression, _navigation: NavigationGrid) -> bool:
	if collected or is_queued_for_deletion() or progression == null:
		return false
	collected = true
	progression.add_gold(amount)
	queue_free()
	return true
