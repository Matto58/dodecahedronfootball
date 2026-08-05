extends Node

class_name MapLoader

static func loadBuiltinMap(mapName: String) -> PackedScene:
	return loadCustomMap("res://maps/" + mapName + ".tscn")

static func loadCustomMap(mapPath: String) -> PackedScene:
	var map = load(mapPath)
	if map == null:
		printerr("failed to load map " + mapPath)
		return null
	return map

static func validateMap(map: Map) -> bool:
	return false
	# todo: remake after making networking stuff work
	if map == null:
		print("tried to validate map, but is null")
		return false
	print("validating map %s by %s" % [map.title, map.author])

	var requiredChildren: Array[String] = ["Timer", "ball", "goalyellow", "goalpurple", "ball reset point", "oob detector", "player", "clanker spawner"]
	var valid = true
	for node in requiredChildren:
		if map.get_node(node) == null:
			print("map is missing node '%s'" % node)
			valid = false

	return valid
