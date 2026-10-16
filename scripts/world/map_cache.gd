extends WorldInteractable
class_name MapCache

const GOLD_SCENE: PackedScene = preload("res://scenes/items/gold_pickup.tscn")
const CLOSED_COLOR := Color(0.65, 0.38, 0.16, 1)
const OPEN_COLOR := Color(0.32, 0.23, 0.16, 1)

var opened := false

func _ready() -> void:
	super._ready()
	add_to_group("map_caches")
	_refresh_visual()

func interact(player: PlayerActor, _progression: PlayerProgression, navigation: NavigationGrid) -> bool:
	if opened or navigation == null or player == null:
		return false
	# Try nearby ground, then the cache's own non-blocking footprint.
	var offsets: Array[Vector2] = [Vector2(32, 0), Vector2(-32, 0), Vector2(0, 32), Vector2(0, -32), Vector2.ZERO]
	for offset: Vector2 in offsets:
		var candidate := global_position + offset
		if not navigation.is_point_on_ground(candidate) or navigation.is_point_blocked(candidate, player):
			continue
		if navigation.find_path(player.global_position, candidate, false, player).is_empty():
			continue
		var pile := GOLD_SCENE.instantiate() as GoldPickup
		pile.amount = randi_range(1, 20)
		get_parent().add_child(pile)
		pile.global_position = candidate
		opened = true
		_refresh_visual()
		return true
	return false

func reset_cache() -> void:
	opened = false
	_refresh_visual()

func _refresh_visual() -> void:
	var visual := get_node_or_null("Visual") as Polygon2D
	if visual != null:
		visual.color = OPEN_COLOR if opened else CLOSED_COLOR
	var lid := get_node_or_null("Lid") as Line2D
	if lid != null:
		lid.position.y = -12.0 if opened else 0.0
