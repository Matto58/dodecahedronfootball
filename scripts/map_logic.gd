extends Map

var canScoreBall = true

func resetBall():
	$ball.linear_velocity = Vector3.ZERO
	$ball.global_position = $"ball reset point".global_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetBall()
	$player/Camera3D/HUD/mapprops/author.text = "by " + author
	$player/Camera3D/HUD/mapprops/name.text = title
	$"oob detector".body_entered.connect(func(body):
		if body == $ball: resetBall()
		elif body == $player: $player.global_position = $"ball reset point".global_position # todo: create a player reset point
		else: print("can't handle ", body, " going out of bounds")
		#print("fuck")
	)
	$goal/ballenter.body_entered.connect(func(body):
		if body.name != "ball": return
		print("firing off! ball has entered goal enter area")
		if not canScoreBall: return
		# todo: add teams
		# todo: figure out which team set off the goal and color the text appropriately
		$player/Camera3D/HUD/AnimationPlayer.play("goal")
		canScoreBall = false
	)
	$goal/ballexit.body_exited.connect(func(body):
		if body.name != "ball": return
		print("firing off! ball has exited goal exit area")
		canScoreBall = true
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
