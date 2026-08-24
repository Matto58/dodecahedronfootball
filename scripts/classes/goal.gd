extends Node3D

class_name Goal

var canScoreBall = true

@export var isYellow: bool = false
@export var purpleMaterial: StandardMaterial3D
@export var yellowMaterial: StandardMaterial3D

## fired when a goal is scored.
## has one parameter: `isYellow` - true if the goal was scored into the yellow goal (so this goal's team)
signal onGoalScore

func _ready() -> void:
	$MeshInstance3D.material_override = yellowMaterial if isYellow else purpleMaterial

	$ballenter.body_entered.connect(func(body):
		if body.name != "ball": return
		#print("firing off! ball has entered goal enter area")
		if not canScoreBall: return
		canScoreBall = false
		onGoalScore.emit(isYellow)
	)
	$ballexit.body_exited.connect(func(body):
		if body.name != "ball": return
		#print("firing off! ball has exited goal exit area")
		canScoreBall = true
	)
