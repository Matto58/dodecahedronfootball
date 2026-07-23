extends Map

# todo: move the player related things to a different script and leave this script to be purely server-side
#    ^^ also categorize all scripts (even everything in classes/) into server and client folders

var scorePurple: int = 0
var scoreYellow: int = 0
var spawnedP: Array[Clanker] = []
var spawnedY: Array[Clanker] = []

const HOLD_BALL_CHECK_FREQUENCY = 18

func resetBall():
	$ball.linear_velocity = Vector3.ZERO
	$ball.global_position = $"ball reset point".global_position

func updateScores():
	$player/Camera3D/HUD/RichTextLabel2.text = "[b][color=\"#7f00ff\"]%d[/color][/b] : [b][color=\"#ff0\"]%d[/color][/b]" % [scorePurple, scoreYellow]

func onGoal(yello: bool):
	if yello: scorePurple += 1
	else: scoreYellow += 1
	$player/Camera3D/HUD/goallabel.label_settings.font_color = Color(1, 1, 0) if yello else Color(0.5, 0, 1)
	$player/Camera3D/HUD/AnimationPlayer.play("goal")
	updateScores()

func timeToStr(seconds: float):
	var minutes = int(seconds/60)
	var secondsComponent = int(seconds - minutes*60)
	return str(minutes) + ":" + str(secondsComponent).pad_zeros(2)

func playerSetBallPos(pos: Vector3, rot: Vector3):
	$ball.global_position = pos
	$ball.global_rotation = rot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetBall()
	updateScores()
	$goalpurple.onGoalScore.connect(onGoal)
	$goalyellow.onGoalScore.connect(onGoal)
	$player.nickname = Settoing.activeInstance.nickname
	$player.isYellow = mainPlayerIsYellow
	$player.initPlayerNickInHUD()
	$player.createNametag()
	$player/Console.map = self
	$player/Camera3D/HUD/mapprops/author.text = "by " + author
	$player/Camera3D/HUD/mapprops/name.text = title
	$"oob detector".body_entered.connect(func(body):
		if body == $ball: resetBall()
		elif body == $player: $player.global_position = $"ball reset point".global_position # todo: create a player reset point
		else: print("can't handle ", body, " going out of bounds")
		#print("fuck")
	)

	print("spawning %d purple and %d yellow bots" % [purpleBots, yellowBots])
	spawnedP = $"clanker spawner".spawn(purpleBots, false)
	spawnedY = $"clanker spawner".spawn(yellowBots, true)
	for pBot in spawnedP:
		initBot(pBot)
		pBot.setBallPos.connect(playerSetBallPos)
	for yBot in spawnedY:
		initBot(yBot)
		yBot.setBallPos.connect(playerSetBallPos)

	$player.setBallPos.connect(playerSetBallPos)

	roundTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$player/Camera3D/HUD/timerlabel.text = timeToStr(roundTimer.time_left)
	if Input.is_action_just_pressed("pause"):
		$player.paused = not $player.paused
		$player/Console.visible = $player.paused

# canHoldBall counter
var chbCtr = 0

func _physics_process(delta: float) -> void:
	$player.sprinting = Input.is_action_pressed("sprint")
	$player.input_dir = Input.get_axis("backward", "forward")
	$player.yumping = Input.is_action_just_pressed("yump")
	$player.lookAroundDir = Input.get_axis("leftalt", "rightalt") if Settoing.activeInstance.useAltPan else Input.get_axis("left", "right")
	$player.sensitivity = Settoing.activeInstance.rotMod
	$player.holdingBall = Input.is_action_pressed("holding_ball")
	$player/Camera3D.rotation.y = PI if Input.is_action_pressed("lookin_back") else 0.0

	chbCtr += 1

	for i in range(spawnedP.size()):
		if spawnedP[i] == null:
			spawnedP.pop_at(i)
		else:
			spawnedP[i].isOnOwnSide = spawnedP[i].global_position.x < 0
			if chbCtr == HOLD_BALL_CHECK_FREQUENCY:
				spawnedP[i].canHoldBall = (spawnedP[i].global_position - $ball.global_position).length() < 3.0
	for i in range(spawnedY.size()):
		if spawnedY[i] == null:
			spawnedY.pop_at(i)
		else:
			spawnedY[i].isOnOwnSide = spawnedY[i].global_position.x < 0
			if chbCtr == HOLD_BALL_CHECK_FREQUENCY:
				spawnedY[i].canHoldBall = (spawnedY[i].global_position - $ball.global_position).length() < 3.0

	if chbCtr == HOLD_BALL_CHECK_FREQUENCY:
		chbCtr = 0
		$player.canHoldBall = ($player.global_position - $ball.global_position).length() < 3.0

func initBot(bot: Clanker):
	bot.purpleGoal = $goalpurple
	bot.yellowGoal = $goalyellow
	bot.ballTarget = $ball
	bot.newTarget(Clanker.AITargets.SelfToBall)
	bot.createNametag()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
