extends Node3D

class_name Goal

var canScoreBall = true

@export var isYellow: bool = false
@export var purpleMaterial: StandardMaterial3D
@export var yellowMaterial: StandardMaterial3D
@export var players: Array[Player]

func _ready() -> void:
	$MeshInstance3D.material_override = yellowMaterial if isYellow else purpleMaterial

	$ballenter.body_entered.connect(func(body):
		if body.name != "ball": return
		print("firing off! ball has entered goal enter area")
		if not canScoreBall: return
		for p in players:
			# reverse colors - if someone scores into the purple goal, we wanna show the goal counts to the yellow team and vice versa
			p.hud.goalLabel.label_settings.font_color = Color(0.5, 0, 1) if isYellow else Color(1, 1, 0) 
			p.hud.animationPlayer.play("goal")
		canScoreBall = false
	)
	$ballexit.body_exited.connect(func(body):
		if body.name != "ball": return
		print("firing off! ball has exited goal exit area")
		canScoreBall = true
	)
