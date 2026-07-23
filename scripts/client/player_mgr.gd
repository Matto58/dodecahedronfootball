extends Node3D

class_name PlayerManager

@export var player: Player
var mapInfo: Map # todo: make a MapInfo resource class that contains server-generated info about the map that the player needs to know
var playerCam: Camera3D
var hud: Control
var consoleWin: Window

# local copies (these will be moved into MapInfo)
var scorePurple: int = 0
var scoreYellow: int = 0

static func timeToStr(seconds: float):
	var minutes = int(seconds/60)
	var secondsComponent = int(seconds - minutes*60)
	return str(minutes) + ":" + str(secondsComponent).pad_zeros(2)

func updateScores():
	hud.get_node("RichTextLabel2").text = "[b][color=\"#7f00ff\"]%d[/color][/b] : [b][color=\"#ff0\"]%d[/color][/b]" % [scorePurple, scoreYellow]

func onGoal(yello: bool):
	if yello: scorePurple += 1
	else: scoreYellow += 1
	hud.get_node("goallabel").label_settings.font_color = Color(1, 1, 0) if yello else Color(0.5, 0, 1)
	hud.get_node("AnimationPlayer").play("goal")
	updateScores()

func _ready() -> void:
	playerCam = player.get_node("Camera3D")
	hud = playerCam.get_node("HUD")
	consoleWin = player.get_node("Console")
	player.nickname = Settoing.activeInstance.nickname
	player.initPlayerNickInHUD()
	player.createNametag()
	updateScores()

func initMapStuff():
	consoleWin.map = mapInfo
	hud.get_node("mapprops/author").text = "by " + mapInfo.author
	hud.get_node("mapprops/name").text = mapInfo.title

	# todo: make this not necessary, as the server will tell the client when a goal happens
	mapInfo.get_node("goalpurple").onGoalScore.connect(onGoal)
	mapInfo.get_node("goalyellow").onGoalScore.connect(onGoal)
	player.setBallPos.connect(mapInfo.playerSetBallPos) # todo: also make this not necessary, because it'll just be a flag the client tells the server

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hud.get_node("timerlabel").text = timeToStr(mapInfo.roundTimer.time_left)
	if Input.is_action_just_pressed("pause"):
		player.paused = not player.paused
		consoleWin.visible = player.paused

func _physics_process(delta: float) -> void:
	player.sprinting = Input.is_action_pressed("sprint")
	player.input_dir = Input.get_axis("backward", "forward")
	player.yumping = Input.is_action_just_pressed("yump")
	player.lookAroundDir = Input.get_axis("leftalt", "rightalt") if Settoing.activeInstance.useAltPan else Input.get_axis("left", "right")
	player.sensitivity = Settoing.activeInstance.rotMod
	player.holdingBall = Input.is_action_pressed("holding_ball")
	playerCam.rotation.y = PI if Input.is_action_pressed("lookin_back") else 0.0
