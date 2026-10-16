extends RefCounted
class_name ExplorationGenerator

const SIZES: Array[int] = [384, 416, 448, 480, 512]
const CELL := 16.0
const CLEARANCE := 10.0
const PASSAGE_HALF_WIDTH := 34.0
const WALL_SIZE := Vector2(24, 112)
const HUB_BOUNDS := Rect2(-420, -230, 420, 460)
const HUB_SPAWN := Vector2(-155, 20)
const MAX_ATTEMPTS := 32

var _hub_ground := PackedVector2Array([Vector2(-420, 0), Vector2(0, -230), Vector2(0, 230)])

func generate(rng: RandomNumberGenerator) -> Dictionary:
	for _attempt in range(MAX_ATTEMPTS):
		var layout := _candidate(rng)
		if _content_valid(layout) and is_layout_connected(layout):
			return layout
	var fallback := _layout(Vector2(448, 448), Vector2(448, 448), 0.0,
		Vector2(200, 104), 0, Vector2(648, -88), 1, Vector2(104, -88), 0)
	assert(is_layout_connected(fallback), "The fallback exploration layout must be connected")
	return fallback

func _candidate(rng: RandomNumberGenerator) -> Dictionary:
	var first_size := Vector2(SIZES[rng.randi_range(0, 4)], SIZES[rng.randi_range(0, 4)])
	var second_size := Vector2(SIZES[rng.randi_range(0, 4)], SIZES[rng.randi_range(0, 4)])
	var passage_limit := floori((first_size.y / 2 - 64) / 32)
	var passage_y := float(rng.randi_range(-passage_limit, passage_limit) * 32)
	var first := Rect2(Vector2(0, -first_size.y / 2), first_size)
	var second := Rect2(Vector2(first_size.x, passage_y - second_size.y / 2), second_size)
	var zones: Array[Rect2] = [first, second]
	var wall_zone := rng.randi_range(0, 1)
	var enemy_zone := rng.randi_range(0, 1)
	var cache_zone := 1 - enemy_zone
	return _layout(first_size, second_size, passage_y,
		_random_point(zones[wall_zone], 96.0, rng), wall_zone,
		_random_point(zones[enemy_zone], 48.0, rng), enemy_zone,
		_random_point(zones[cache_zone], 48.0, rng), cache_zone)

func _random_point(bounds: Rect2, margin: float, rng: RandomNumberGenerator) -> Vector2:
	var minimum := Vector2i(ceili((bounds.position.x + margin - 8) / CELL), ceili((bounds.position.y + margin - 8) / CELL))
	var maximum := Vector2i(floori((bounds.end.x - margin - 8) / CELL), floori((bounds.end.y - margin - 8) / CELL))
	return Vector2(rng.randi_range(minimum.x, maximum.x), rng.randi_range(minimum.y, maximum.y)) * CELL + Vector2(8, 8)

func _layout(first_size: Vector2, second_size: Vector2, passage_y: float,
		wall: Vector2, wall_zone: int, enemy: Vector2, enemy_zone: int,
		cache: Vector2, cache_zone: int) -> Dictionary:
	var first := Rect2(Vector2(0, -first_size.y / 2), first_size)
	var second := Rect2(Vector2(first_size.x, passage_y - second_size.y / 2), second_size)
	var top := minf(first.position.y, second.position.y)
	var bottom := maxf(first.end.y, second.end.y)
	var barriers: Array[Rect2] = [
		Rect2(-12, -230, 24, 196), Rect2(-12, 34, 24, 196),
		Rect2(first_size.x - 12, top, 24, passage_y - PASSAGE_HALF_WIDTH - top),
		Rect2(first_size.x - 12, passage_y + PASSAGE_HALF_WIDTH, 24, bottom - passage_y - PASSAGE_HALF_WIDTH)]
	return {"zones": [first, second], "passage": Vector2(first_size.x, passage_y),
		"wall": wall, "wall_zone": wall_zone, "enemy": enemy, "enemy_zone": enemy_zone,
		"cache": cache, "cache_zone": cache_zone, "barriers": barriers}

func _content_valid(layout: Dictionary) -> bool:
	var wall := Rect2(Vector2(layout["wall"]) - WALL_SIZE / 2, WALL_SIZE).grow(48)
	return not wall.has_point(layout["enemy"]) and not wall.has_point(layout["cache"]) and Vector2(layout["enemy"]).distance_to(layout["cache"]) >= 72.0

func bounds_for(layout: Dictionary) -> Rect2:
	var bounds := HUB_BOUNDS
	for zone: Rect2 in layout["zones"]:
		bounds = bounds.merge(zone)
	return bounds

func is_ground(layout: Dictionary, point: Vector2) -> bool:
	if Geometry2D.is_point_in_polygon(point, _hub_ground):
		return true
	for zone: Rect2 in layout["zones"]:
		if zone.has_point(point):
			return true
	return false

func is_layout_connected(layout: Dictionary) -> bool:
	# Validate the complete area, not just a route between the two entrances.
	var bounds := bounds_for(layout)
	var origin := (bounds.position / CELL).floor() * CELL - Vector2.ONE * CELL
	var size := Vector2i(((bounds.end - origin) / CELL).ceil()) + Vector2i.ONE
	var walkable: Dictionary = {}
	var wall := Rect2(Vector2(layout["wall"]) - WALL_SIZE / 2, WALL_SIZE).grow(CLEARANCE)
	for y in range(size.y):
		for x in range(size.x):
			var id := Vector2i(x, y)
			var point := origin + Vector2(id) * CELL + Vector2.ONE * CELL / 2
			if not _clear_ground(layout, point) or wall.has_point(point):
				continue
			if point.distance_to(layout["enemy"]) <= 16.0 + CLEARANCE:
				continue
			var blocked := false
			for barrier: Rect2 in layout["barriers"]:
				if barrier.grow(CLEARANCE).has_point(point):
					blocked = true
					break
			if not blocked:
				walkable[id] = true
	var start := Vector2i(((HUB_SPAWN - origin) / CELL).floor())
	var cache_cell := Vector2i(((Vector2(layout["cache"]) - origin) / CELL).floor())
	if not walkable.has(start) or not walkable.has(cache_cell):
		return false
	var visited: Dictionary = {start: true}
	var queue: Array[Vector2i] = [start]
	var head := 0
	while head < queue.size():
		var current := queue[head]
		head += 1
		for step: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor := current + step
			if walkable.has(neighbor) and not visited.has(neighbor):
				visited[neighbor] = true
				queue.append(neighbor)
	return visited.size() == walkable.size()

func _clear_ground(layout: Dictionary, point: Vector2) -> bool:
	if not is_ground(layout, point):
		return false
	for index in range(8):
		if not is_ground(layout, point + Vector2.from_angle(TAU * index / 8.0) * CLEARANCE):
			return false
	return true
