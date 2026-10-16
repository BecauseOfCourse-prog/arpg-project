extends RefCounted
class_name WorldTestFixture

# Movement/combat regression tests use the authored wall and enemy coordinates.
# Procedural generation is covered by procedural_exploration_test.gd.
static func create_main() -> Node:
	var main := (load("res://scenes/main/main.tscn") as PackedScene).instantiate()
	main.get_node("World").set("procedural_generation_enabled", false)
	return main
