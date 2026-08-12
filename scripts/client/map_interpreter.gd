extends Node3D

var net: NetInterface
var pMgr: PlayerManager
var connIP: String
var connPort: int
var prefYellow: bool
var canSendData: bool = false

var diffVerPopupShown: bool = false

func goBackToMenu():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func continueInit():
	print("joining")
	net.cPlayerJoin.rpc(pMgr.player.i)
	print(pMgr.player.i)

	print("RECONSTRUCTING MAP:")
	print("getting map")
	net.cGetMapInfo.rpc()
	for p in pMgr.mapInfo.players:
		print("- reconstructing player " + p.nickname)
		pMgr.handleNewPlayer(p)
	print("- reconstructing objects")
	add_child(pMgr.mapInfo.mapObjs)
	print("ready!")
	canSendData = true

func imOuttaHere():
	net.peer.disconnect_peer(1)
	goBackToMenu()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("CONNECTING")
	net = NetInterface.new()
	add_child(net)
	net.multiplayer.connected_to_server.connect(func():
		net.cGetServerSummary.rpc())
	net.multiplayer.connection_failed.connect(func():
		DHMain.popup(self, "Error!",
			"Could not connect to the server.\n" +
			"Check if the IP and port are correct and that the server is online.\n" +
			"(tried to connect to %s:%d)" % [connIP, connPort], goBackToMenu).popup_centered_clamped())
	if not net.initClient(connPort, connIP):
		DHMain.popup(self, "Error!",
			"Could not init the net interface client.\n" +
			"Check if you're connected to the internet.\n" +
			"(tried to connect to %s:%d)" % [connIP, connPort], goBackToMenu).popup_centered_clamped()
		return
	net.multiplayer.server_disconnected.connect(func():
		DHMain.popup(self, "Disconnected", "You were disconnected from %s:%d." % [connIP, connPort], goBackToMenu).popup_centered_clamped())
	print("CREATING SELF")
	pMgr = PlayerManager.new()
	pMgr.player = LocalPlayer.new()
	# PlayerManager._ready initializes the nickname - we only need to set the preferred team
	pMgr.player.i.isYellow = prefYellow
	add_child(pMgr.player)
	add_child(pMgr)
	pMgr.pauseMenu.mapInterpreter = self # so that the pause menu can call imOuttaHere()
	pMgr.consoleWin.net = net
	print("connecting...")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pMgr == null: return
	if not diffVerPopupShown and pMgr.mapSumm != null:
		if DHMain.GAME_VER != pMgr.mapSumm.serverVersion:
			# todo: create signals in NetInterface for map summary/map info/player info callbacks
			DHMain.ask(self, "Warning",
				"The server has a different version from your game. (server: %s, client: %s)\n" % [pMgr.mapSumm.serverVersion, DHMain.GAME_VER] +
				"Trying to join and play WILL lead to errors and unknown behavior.\n" +
				"Knowing this, would you like to join anyway?",
				"I am aware of the risks, let me join!", "On second thought...",
				continueInit, imOuttaHere).popup_centered_clamped()
			diffVerPopupShown = true
		continueInit()
	if pMgr.mapInfo == null: return
	if not canSendData: return
	net.cPlayerGetInfo.rpc() # todo: this might be a bit slow?
	net.cPlayerApplyInput.rpc(pMgr.player.inp)
