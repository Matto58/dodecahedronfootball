extends Control

class_name PlayerHUD

@export_group("Programatically set values")
@export var animationPlayer: AnimationPlayer
@export var goalLabel: Label

func _ready() -> void:
	animationPlayer = $AnimationPlayer
	goalLabel = $goallabel
