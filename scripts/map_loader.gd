extends Node

class_name MapLoader

static func loadBuiltinMap(name: String) -> PackedScene:
	var map = load("res://maps/" + name + ".tscn")
	if map == null:
		printerr("FAILED TO LOAD BUILT-IN MAP '" + name + "'")
		return null
	return map
