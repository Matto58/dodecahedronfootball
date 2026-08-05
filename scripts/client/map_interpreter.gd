extends Node3D

var net: NetInterface
var pMgr: PlayerManager
var connIP: String
var connPort: int
var prefYellow: bool
var mapInfo: MapInfo
var otherPlayers: Array[LocalPlayer]

func goBackToMenu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func popup(title: String, text: String, onClose: Callable) -> AcceptDialog:
	var p = ConfirmationDialog.new()
	p.title = title
	p.dialog_text = text
	add_child(p)
	p.popup_centered_clamped()
	p.close_requested.connect(onClose)
	p.confirmed.connect(onClose)
	return p

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	net = NetInterface.new()
	if not net.initClient(connPort, connIP):
		popup("Error!", "Could not init the net interface client.\nCheck if IP/port is correct, you're connected to the internet etc.\n(tried to connect to %s:%d)" % [connIP, connPort], goBackToMenu)
		return
	net.multiplayer.server_disconnected.connect(func():
		popup("Disconnected", "You were disconnected from %s:%d." % [connIP, connPort], goBackToMenu))

	print(net.cPlayerJoin(pMgr.player.i))
	pMgr.consoleWin.net = net
	print("RECONSTRUCTING MAP:")
	mapInfo = net.cGetMapInfo()
	for p in mapInfo.players:
		print("- reconstructing player " + p.nickname)
		var playerObj = LocalPlayer.new()
		playerObj.i = p
		add_child(playerObj)
		otherPlayers.append(playerObj)
	print("- reconstructing objects")
	add_child(mapInfo.mapObjs)
	print("ready!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	net.cPlayerApplyInput(pMgr.player.inp)
