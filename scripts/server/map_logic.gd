extends Map

var scorePurple: int = 0
var scoreYellow: int = 0
var spawnedP: Array[Clanker] = []
var spawnedY: Array[Clanker] = []

const HOLD_BALL_CHECK_FREQUENCY = 18

func resetBall():
	$ball.linear_velocity = Vector3.ZERO
	$ball.global_position = $"ball reset point".global_position

func playerSetBallPos(pos: Vector3, rot: Vector3):
	$ball.global_position = pos
	$ball.global_rotation = rot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	resetBall()
	# todo: every piece of logic that mentions $PlayerManager.player should be moved into the player manager itself
	#       and the player manager should be in the clientside instance of the map
	#       the player needn't the full instance of the map, only the players, map objects and score
	$"oob detector".body_entered.connect(func(body):
		if body == $ball: resetBall()
		elif body == $PlayerManager.player: $PlayerManager.player.global_position = $"ball reset point".global_position # todo: create a player reset point
		else: print("can't handle ", body, " going out of bounds")
		#print("fuck")
	)
	$PlayerManager.mapInfo = self
	$PlayerManager.initMapStuff()

	print("spawning %d purple and %d yellow bots" % [purpleBots, yellowBots])
	spawnedP = $"clanker spawner".spawn(purpleBots, false)
	spawnedY = $"clanker spawner".spawn(yellowBots, true)
	for pBot in spawnedP:
		initBot(pBot)
		pBot.setBallPos.connect(playerSetBallPos)
	for yBot in spawnedY:
		initBot(yBot)
		yBot.setBallPos.connect(playerSetBallPos)

	roundTimer.start()

# canHoldBall counter
var chbCtr = 0

func _physics_process(delta: float) -> void:
	# todo: link the canHoldBall check to a player signal
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
		chbCtr = 0
		$PlayerManager.player.canHoldBall = ($PlayerManager.player.global_position - $ball.global_position).length() < 3.0

func initBot(bot: Clanker):
	bot.purpleGoal = $goalpurple
	bot.yellowGoal = $goalyellow
	bot.ballTarget = $ball
	bot.newTarget(Clanker.AITargets.SelfToBall)
	bot.createNametag()

func _on_timer_timeout() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
