extends Node2D
class_name NavigationGrid

const GRID_ORIGIN := Vector2(-432.0, -240.0)
const GRID_SIZE := Vector2i(54, 30)
const CELL_SIZE := 16.0
const PLAYER_CLEARANCE := 10.0

var _astar := AStarGrid2D.new()
var _ground_polygons: Array[PackedVector2Array] = []
var _solid_signature := "uninitialized"

func _ready() -> void:
	add_to_group("world_navigation")
	_astar.region = Rect2i(Vector2i.ZERO, GRID_SIZE)
	_astar.cell_size = Vector2(CELL_SIZE, CELL_SIZE)
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_astar.update()
	for ground: Polygon2D in get_tree().get_nodes_in_group("walkable_ground"):
		_ground_polygons.append(_global_polygon(ground))

func find_path(start: Vector2, target: Vector2, resolve_boundary: bool, mover: CollisionObject2D) -> PackedVector2Array:
	_refresh_solids(mover)
	var start_id := _nearest_walkable_id(start)
	if start_id.x < 0:
		return PackedVector2Array()
	var target_id := _cell_id(target)
	var target_is_walkable := _is_walkable(target_id) and _circle_on_ground(target)
	if not target_is_walkable:
		if not resolve_boundary:
			return PackedVector2Array()
		target_id = _closest_reachable_id(start_id, target)
	elif _astar.is_point_solid(target_id):
		if not resolve_boundary:
			return PackedVector2Array()
		target_id = _closest_reachable_id(start_id, target)
	if target_id.x < 0:
		return PackedVector2Array()
	var ids := _astar.get_id_path(start_id, target_id)
	if ids.is_empty():
		return PackedVector2Array()
	var points := PackedVector2Array([start])
	for index in range(1, ids.size()):
		points.append(_cell_center(ids[index]))
	if points.is_empty() or points[points.size() - 1].distance_to(target) > CELL_SIZE:
		points.append(_cell_center(target_id))
	if target_is_walkable and not _astar.is_point_solid(target_id):
		points[points.size() - 1] = target
	return _smooth_path(points, mover)

func _refresh_solids(mover: CollisionObject2D) -> void:
	var signature_parts: PackedStringArray = []
	for obstacle: Node2D in get_tree().get_nodes_in_group("movement_obstacles"):
		signature_parts.append("%s:%s" % [obstacle.get_instance_id(), obstacle.global_transform])
	var signature := "|".join(signature_parts)
	if signature == _solid_signature:
		return
	_solid_signature = signature
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var id := Vector2i(x, y)
			var point := _cell_center(id)
			var blocked := not _circle_on_ground(point)
			if not blocked:
				blocked = _circle_blocked(point, mover)
			_astar.set_point_solid(id, blocked)

func _circle_blocked(point: Vector2, mover: CollisionObject2D) -> bool:
	var query := PhysicsShapeQueryParameters2D.new()
	var circle := CircleShape2D.new()
	circle.radius = PLAYER_CLEARANCE
	query.shape = circle
	query.transform = Transform2D(0.0, point)
	query.collision_mask = 1
	if mover != null:
		query.exclude = [mover.get_rid()]
	query.collide_with_areas = false
	query.collide_with_bodies = true
	return not get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty()

func is_point_on_ground(point: Vector2) -> bool:
	if _ground_polygons.is_empty():
		for ground: Polygon2D in get_tree().get_nodes_in_group("walkable_ground"):
			_ground_polygons.append(_global_polygon(ground))
	return _point_on_ground(point)

func _global_polygon(ground: Polygon2D) -> PackedVector2Array:
	var transformed := PackedVector2Array()
	for vertex in ground.polygon:
		transformed.append(ground.to_global(vertex))
	return transformed

func is_point_blocked(point: Vector2, mover: CollisionObject2D) -> bool:
	return _circle_blocked(point, mover)

func _point_on_ground(point: Vector2) -> bool:
	for polygon in _ground_polygons:
		if Geometry2D.is_point_in_polygon(point, polygon):
			return true
	return false

func _circle_on_ground(point: Vector2) -> bool:
	for sample_index in range(8):
		var angle := TAU * float(sample_index) / 8.0
		if not _point_on_ground(point + Vector2.from_angle(angle) * PLAYER_CLEARANCE):
			return false
	return _point_on_ground(point)

func _cell_id(point: Vector2) -> Vector2i:
	var local := (point - GRID_ORIGIN) / CELL_SIZE
	return Vector2i(floori(local.x), floori(local.y))

func _cell_center(id: Vector2i) -> Vector2:
	return GRID_ORIGIN + Vector2(id) * CELL_SIZE + Vector2.ONE * CELL_SIZE * 0.5

func _is_walkable(id: Vector2i) -> bool:
	return id.x >= 0 and id.y >= 0 and id.x < GRID_SIZE.x and id.y < GRID_SIZE.y and not _astar.is_point_solid(id)

func _nearest_walkable_id(point: Vector2) -> Vector2i:
	var start := _cell_id(point)
	var best := Vector2i(-1, -1)
	var best_distance := INF
	for y in range(maxi(0, start.y - 3), mini(GRID_SIZE.y, start.y + 4)):
		for x in range(maxi(0, start.x - 3), mini(GRID_SIZE.x, start.x + 4)):
			var id := Vector2i(x, y)
			if _is_walkable(id):
				var distance := point.distance_squared_to(_cell_center(id))
				if distance < best_distance:
					best = id
					best_distance = distance
	return best

func _closest_reachable_id(start: Vector2i, target: Vector2) -> Vector2i:
	var best := start
	var best_distance := INF
	var queue: Array[Vector2i] = [start]
	var visited: Dictionary = {start: true}
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		var distance := target.distance_squared_to(_cell_center(current))
		if distance < best_distance:
			best = current
			best_distance = distance
		for y_step in range(-1, 2):
			for x_step in range(-1, 2):
				if x_step == 0 and y_step == 0:
					continue
				var neighbor := current + Vector2i(x_step, y_step)
				if visited.has(neighbor) or not _is_walkable(neighbor):
					continue
				if x_step != 0 and y_step != 0:
					if not _is_walkable(current + Vector2i(x_step, 0)) or not _is_walkable(current + Vector2i(0, y_step)):
						continue
				visited[neighbor] = true
				queue.append(neighbor)
	return best

func _smooth_path(points: PackedVector2Array, mover: CollisionObject2D) -> PackedVector2Array:
	if points.size() < 3:
		return points
	var result := PackedVector2Array([points[0]])
	var anchor := 0
	while anchor < points.size() - 1:
		var candidate := points.size() - 1
		while candidate > anchor + 1 and not _segment_clear(points[anchor], points[candidate], mover):
			candidate -= 1
		result.append(points[candidate])
		anchor = candidate
	return result

func _segment_clear(from: Vector2, to: Vector2, mover: CollisionObject2D) -> bool:
	var steps := maxi(1, ceili(from.distance_to(to) / (CELL_SIZE * 0.5)))
	for step in range(steps + 1):
		var point := from.lerp(to, float(step) / float(steps))
		if not _circle_on_ground(point) or _circle_blocked(point, mover):
			return false
	return true
