extends Node3D

class_name Map

@export_group("Properties")
@export var title: String
@export var author: String
@export var maxPlayersPerTeam: int
@export var roundTimer: Timer
@export var purpleGoal: Node3D
@export var yellowGoal: Node3D
@export var mapObjs: Node3D
@export var oobArea: Area3D
@export var ball: RigidBody3D
@export var ballResetPoint: Vector3
@export var spawnpointsPurple: Array[Vector4]
@export var spawnpointsYellow: Array[Vector4]
@export var botSpawner: ClankerSpawner

var scorePurple: int = 0
var scoreYellow: int = 0

var net: NetInterface
var players: Dictionary[int, Player]
var console: Console

const HOLD_BALL_CHECK_FREQUENCY = 18

func resetBall():
	ball.linear_velocity = Vector3.ZERO
	ball.global_position = ballResetPoint

func playerSetBallPos(pos: Vector3, rot: Vector3):
	ball.global_position = pos
	ball.global_rotation = rot

func generateInfo() -> MapInfo:
	var i = MapInfo.new()
	i.serverVersion = DHMain.GAME_VER
	i.name = title
	i.author = author
	i.roundTimer = roundTimer
	i.mapObjs = mapObjs
	i.players = players.values().map(func(p): return p.i)
	i.currentPScore = scorePurple
	i.currentYScore = scoreYellow
	return i

func handleJoin(player: PlayerInfo) -> PlayerInfo:
	# todo: split scenes into server/client
	var p: Player = Player.new()
	p.i = player
	add_child(p)
	players[player.netID] = p

	var spawnpoints: Array[Vector4] = spawnpointsYellow if player.isYellow else spawnpointsPurple
	var spawnpoint4 = spawnpoints.pick_random()
	p.global_position = Vector3(spawnpoint4.x, spawnpoint4.y, spawnpoint4.z)
	p.global_rotation = Vector3(0.0, spawnpoint4.w, 0.0)
	p.i.position = global_position
	p.i.rotation = global_rotation
	return p.i
	# do something else???

func handleLeave(playerNetID: int):
	var p = players[playerNetID]
	remove_child(p)
	players.erase(playerNetID)
	p.queue_free()

func countTeamMembers() -> Vector2i:
	var purples = 0
	var yellows = 0
	for player in players.values():
		if player.i.isYellow:
			yellows += 1
		else:
			purples += 1
	return Vector2i(purples, yellows)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if net == null:
		net = NetInterface.new()
		add_child(net)
		net.initServer()
	if console == null:
		console = Console.new()
	resetBall()
	net.map = self
	botSpawner.m = self
	console.map = self
	# todo: every piece of logic that mentions $PlayerManager.player should be moved into the player manager itself
	#       and the player manager should be in the clientside instance of the map
	#       the player needn't the full instance of the map, only the players, map objects and score
	oobArea.body_entered.connect(func(body):
		if body == ball: resetBall()
		#elif body == $PlayerManager.player: $PlayerManager.player.global_position = $"ball reset point".global_position # todo: create a player reset point
		else: print("can't handle ", body, " going out of bounds")
		#print("fuck")
	)

	#print("spawning %d purple and %d yellow bots" % [purpleBots, yellowBots])
	#spawnedP = $"clanker spawner".spawn(purpleBots, false)
	#spawnedY = $"clanker spawner".spawn(yellowBots, true)
	#for pBot in spawnedP:
	#	initBot(pBot)
	#	pBot.setBallPos.connect(playerSetBallPos)
	#for yBot in spawnedY:
	#	initBot(yBot)
	#	yBot.setBallPos.connect(playerSetBallPos)

	roundTimer.start()

# canHoldBall counter
var chbCtr = 0

func _physics_process(delta: float) -> void:
	# todo: link the canHoldBall check to a player signal
	chbCtr += 1

	for p in players.values():
		p.isOnOwnSide = p.global_position.x < 0
		if chbCtr == HOLD_BALL_CHECK_FREQUENCY:
			chbCtr = 0
			p.canHoldBall = (p.global_position - ball.global_position).length() < 3.0

func initBot(bot: Clanker):
	bot.purpleGoal = purpleGoal
	bot.yellowGoal = yellowGoal
	bot.ballTarget = ball
	bot.newTarget(Clanker.AITargets.SelfToBall)

func _on_timer_timeout() -> void:
	#get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	for p in players.keys():
		net.disconnectPlayer(p)
