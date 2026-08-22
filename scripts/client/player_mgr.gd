extends Node3D

class_name PlayerManager

var player: LocalPlayer
var otherPlayers: Dictionary[int, LocalPlayer]
var mapInfo: MapInfo
var mapSumm: MapSummary
var playerCam: Camera3D
var hud: Control
var pauseMenu: Control
var consoleWin: Window

const PURPLE_MATERIAL = preload("res://mats/goalourple.tres")
const YELLOW_MATERIAL = preload("res://mats/goalyello.tres")

static func timeToStr(seconds: float):
	var minutes = int(seconds/60)
	var secondsComponent = int(seconds - minutes*60)
	return str(minutes) + ":" + str(secondsComponent).pad_zeros(2)

func updateScores():
	if mapInfo == null: return
	hud.get_node("RichTextLabel2").text = "[b][color=\"#7f00ff\"]%d[/color][/b] : [b][color=\"#ff0\"]%d[/color][/b]" % [mapInfo.currentPScore, mapInfo.currentYScore]

func initPlayerNickInHUD():
	hud.get_node("RichTextLabel").append_text("[color=\"#999\"]Playing as[/color] [b][color=\"#%s\"]%s[/color][/b]" % ["ff0" if player.i.isYellow else "7f00ff", player.i.nickname])

static func createNametag(p: Node3D):
	var tag = Label3D.new()
	if p.has_node("nametag"):
		tag = p.get_node("nametag")
	else:
		p.add_child(tag)
	tag.position = Vector3(0, 1.25, 0)
	tag.name = "nametag"
	tag.text = p.i.nickname
	tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	tag.font_size = 64

func handleNewPlayer(p: PlayerInfo):
	var playerObj = LocalPlayer.new()
	playerObj.i = p
	add_child(playerObj)
	otherPlayers[p.netID] = playerObj

func handlePlayerLeave(id: int):
	var p = otherPlayers[id]
	remove_child(p)
	otherPlayers.erase(id)
	p.queue_free()

func giveCamera():
	playerCam = Camera3D.new()
	player.add_child(playerCam)
	playerCam.position = Vector3(0.0, 0.75, 0.0)
	playerCam.rotation_degrees = Vector3(-30.0, 0.0, 0.0)
	hud = preload("res://scenes/hud.tscn").instantiate()
	playerCam.add_child(hud)
	pauseMenu = preload("res://scenes/pause_menu.tscn").instantiate()
	playerCam.add_child(pauseMenu)
	pauseMenu.hide()

func giveConsole():
	consoleWin = preload("res://scenes/console.tscn").instantiate()
	player.add_child(consoleWin)

func _ready() -> void:
	#consoleWin = player.get_node("Console")
	player.i.nickname = Settoing.activeInstance.nickname
	giveCamera()
	giveConsole()
	initPlayerNickInHUD()
	updateScores()

func initMapStuff():
	#consoleWin.map = mapInfo
	hud.get_node("mapprops/author").text = "by " + mapInfo.author
	hud.get_node("mapprops/name").text = mapInfo.title

	#mapInfo.get_node("goalpurple").onGoalScore.connect(onGoal)
	#mapInfo.get_node("goalyellow").onGoalScore.connect(onGoal)
	#player.setBallPos.connect(mapInfo.playerSetBallPos) # todo: also make this not necessary, because it'll just be a flag the client tells the server

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		player.paused = not player.paused
		consoleWin.visible = player.paused
	if mapInfo == null: return
	hud.get_node("timerlabel").text = timeToStr(mapInfo.roundTimer.time_left)

func _physics_process(delta: float) -> void:
	player.inp.sprinting = Input.is_action_pressed("sprint")
	player.inp.input_dir = Input.get_axis("backward", "forward")
	player.inp.yumping = Input.is_action_just_pressed("yump")
	player.inp.lookAroundDir = Input.get_axis("leftalt", "rightalt") if Settoing.activeInstance.useAltPan else Input.get_axis("left", "right")
	player.inp.sensitivity = Settoing.activeInstance.rotMod
	player.inp.holdingBall = Input.is_action_pressed("holding_ball")
	playerCam.rotation.y = PI if Input.is_action_pressed("lookin_back") else 0.0
	player.global_position = player.i.position
	player.global_rotation = player.i.rotation
