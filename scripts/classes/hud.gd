extends Control

class_name PlayerHUD

@export_group("These are set programatically")
@export var animationPlayer: AnimationPlayer
@export var goalLabel: Label

func _ready() -> void:
	animationPlayer = $AnimationPlayer
	goalLabel = $goallabel
