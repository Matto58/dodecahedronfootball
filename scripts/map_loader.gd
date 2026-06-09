extends Node

class_name MapLoader

static func loadBuiltinMap(mapName: String) -> PackedScene:
	var map = load("res://maps/" + mapName + ".tscn")
	if map == null:
		printerr("FAILED TO LOAD BUILT-IN MAP '" + mapName + "'")
		return null
	return map
