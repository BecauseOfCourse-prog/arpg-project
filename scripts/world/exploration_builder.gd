extends RefCounted
class_name ExplorationBuilder

const ENEMY_SCENE: PackedScene = preload("res://scenes/actors/enemy.tscn")
const CACHE_SCENE: PackedScene = preload("res://scenes/world/map_cache.tscn")
const SECOND_DEFINITION: WorldAreaDefinition = preload("res://data/areas/exploration_2.tres")

func build(world: Node2D, layout: Dictionary) -> void:
	var first := world.get_node("Exploration") as WorldArea
	for child: Node in first.get_children():
		child.free()
	for node_name: String in ["Exploration2", "ExplorationBoundary"]:
		var old := world.get_node_or_null(node_name)
		if old != null:
			old.free()
	if not first.is_in_group("exploration_zones"):
		first.add_to_group("exploration_zones")
	var second := WorldArea.new()
	second.name = "Exploration2"
	second.y_sort_enabled = true
	second.definition = SECOND_DEFINITION
	world.add_child(second)
	second.add_to_group("exploration_zones")
	var areas: Array[WorldArea] = [first, second]
	for index in range(2):
		var bounds: Rect2 = layout["zones"][index]
		var ground := Polygon2D.new()
		ground.name = "Ground"
		ground.polygon = _rect_polygon(bounds)
		ground.color = Color(0.29, 0.25, 0.19) if index == 0 else Color(0.25, 0.28, 0.20)
		ground.z_index = -1
		areas[index].add_child(ground)
		ground.add_to_group("walkable_ground")
		var label := Label.new()
		label.name = "Title"
		label.text = "EXPLORATION %d" % (index + 1)
		label.position = bounds.get_center() - Vector2(75, 0)
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		areas[index].add_child(label)
	var wall_bounds := Rect2(Vector2(layout["wall"]) - ExplorationGenerator.WALL_SIZE / 2, ExplorationGenerator.WALL_SIZE)
	_add_wall(areas[layout["wall_zone"]], "TestWall", wall_bounds, Color(0.35, 0.32, 0.27))
	var enemy := ENEMY_SCENE.instantiate() as EnemyActor
	enemy.name = "TrainingSentinel"
	enemy.position = layout["enemy"]
	areas[layout["enemy_zone"]].add_child(enemy)
	var cache := CACHE_SCENE.instantiate() as MapCache
	cache.name = "TestCache"
	cache.position = layout["cache"]
	areas[layout["cache_zone"]].add_child(cache)
	var boundary := Node2D.new()
	boundary.name = "ExplorationBoundary"
	boundary.y_sort_enabled = true
	world.add_child(boundary)
	_add_wall(boundary, "NorthBoundary", layout["barriers"][2], Color(0.24, 0.30, 0.28))
	_add_wall(boundary, "SouthBoundary", layout["barriers"][3], Color(0.24, 0.30, 0.28))
	var marker := Polygon2D.new()
	marker.name = "TransitionMarker"
	marker.position = layout["passage"]
	marker.polygon = _rect_polygon(Rect2(-8, -34, 16, 68))
	marker.color = Color(0.75, 0.65, 0.36)
	boundary.add_child(marker)

func _add_wall(parent: Node2D, node_name: String, bounds: Rect2, color: Color) -> void:
	var wall := StaticBody2D.new()
	wall.name = node_name
	wall.position = bounds.get_center()
	var visual := Polygon2D.new()
	visual.name = "WallVisual"
	visual.polygon = _rect_polygon(Rect2(-bounds.size / 2, bounds.size))
	visual.color = color
	wall.add_child(visual)
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = bounds.size
	collision.shape = shape
	wall.add_child(collision)
	parent.add_child(wall)
	wall.add_to_group("movement_obstacles")

func _rect_polygon(bounds: Rect2) -> PackedVector2Array:
	return PackedVector2Array([bounds.position, Vector2(bounds.end.x, bounds.position.y), bounds.end, Vector2(bounds.position.x, bounds.end.y)])
