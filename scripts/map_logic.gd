extends Map

var scorePurple: int = 0
var scoreYellow: int = 0

func resetBall():
	$ball.linear_velocity = Vector3.ZERO
	$ball.global_position = $"ball reset point".global_position

func onGoal(yello: bool):
	if yello: scoreYellow += 1
	else: scorePurple += 1
	$player/Camera3D/HUD/goalLabel.label_settings.font_color = Color(1, 1, 0) if yello else Color(0.5, 0, 1)
	$player/Camera3D/HUD/AnimationPlayer.play("goal")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetBall()
	$goalpurple.onGoalScore.connect(onGoal)
	$goalyellow.onGoalScore.connect(onGoal)
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
