extends Node3D

class_name LocalPlayer

var i: PlayerInfo
var inp: PlayerInputs
const PURPLE_MATERIAL = preload("res://mats/goalourple.tres")
const YELLOW_MATERIAL = preload("res://mats/goalyello.tres")

func _init():
	i = PlayerInfo.new()
	inp = PlayerInputs.new()

func _physics_process(delta: float) -> void:
	global_position = i.position
	global_rotation = i.rotation
