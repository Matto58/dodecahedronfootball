extends Map

func resetBall():
	$ball.linear_velocity = Vector3.ZERO
	$ball.global_position = $"ball reset point".global_position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetBall()
	$player.nickname = Settoing.activeInstance.nickname
	$player.isYellow = randf() >= 0.5
	$player.initPlayerNickInHUD()
	$player/Camera3D/HUD/mapprops/author.text = "by " + author
	$player/Camera3D/HUD/mapprops/name.text = title
	$"oob detector".body_entered.connect(func(body):
		if body == $ball: resetBall()
		elif body == $player: $player.global_position = $"ball reset point".global_position # todo: create a player reset point
		else: print("can't handle ", body, " going out of bounds")
		#print("fuck")
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
