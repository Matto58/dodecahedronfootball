extends Map

# todo: move the player related things to a different script and leave this script to be purely server-side
#    ^^ also categorize all scripts (even everything in classes/) into server and client folders

var scorePurple: int = 0
var scoreYellow: int = 0
var spawnedP: Array[Clanker] = []
var spawnedY: Array[Clanker] = []

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetBall()
	updateScores()
	$goalpurple.onGoalScore.connect(onGoal)
	$goalyellow.onGoalScore.connect(onGoal)
	$player.nickname = Settoing.activeInstance.nickname
	$player.isYellow = mainPlayerIsYellow
	$player.initPlayerNickInHUD()
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
		pBot.purpleGoal = $goalpurple
		pBot.yellowGoal = $goalyellow
		pBot.ballTarget = $ball
		pBot.newTarget(Clanker.AITargets.SelfToBall)
	for yBot in spawnedY:
		yBot.purpleGoal = $goalpurple
		yBot.yellowGoal = $goalyellow
		yBot.ballTarget = $ball
		yBot.newTarget(Clanker.AITargets.SelfToBall)

	roundTimer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$player/Camera3D/HUD/timerlabel.text = timeToStr(roundTimer.time_left)

func _physics_process(delta: float) -> void:
	$player.sprinting = Input.is_action_pressed("sprint")
	$player.input_dir = Input.get_axis("forward", "backward")
	$player.yumping = Input.is_action_just_pressed("yump")
	$player.lookAroundDir = -(Input.get_axis("leftalt", "rightalt") if Settoing.activeInstance.useAltPan else Input.get_axis("left", "right"))
	$player.sensitivity = Settoing.activeInstance.rotMod

	for pBot in spawnedP:
		pBot.isOnOwnSide = pBot.global_position.x < 0
	for yBot in spawnedY:
		yBot.isOnOwnSide = yBot.global_position.x > 0
