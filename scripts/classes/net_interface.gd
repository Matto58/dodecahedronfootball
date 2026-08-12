extends Node

class_name NetInterface

# NAMING SCHEME ON FUNCTIONS:
# c* - called by the client but executed on the server
# s* - called by the server but executed on the client - by extension, sCB* - callbacks of equivalent c* functions
# everything else - called and executed on the server

var peer: ENetMultiplayerPeer
var map # null if client (hopefully)
var pMgr # null if server (hopefully)

const DEFAULT_SERVER_PORT = 6200

func initServer(port: int = DEFAULT_SERVER_PORT) -> bool:
	print("initServer: creating server")
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_server(port)
	if result != OK:
		printerr("initServer: could not create server: %s" % result)
		return false
	multiplayer.multiplayer_peer = peer
	print("initServer: ready. please initialize the map")
	return true

func initClient(port: int = DEFAULT_SERVER_PORT, ip: String = "127.0.0.1") -> bool:
	print("initClient: creating client")
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, port)
	if result != OK:
		printerr("initServer: could not create server: %s" % result)
		return false
	multiplayer.multiplayer_peer = peer
	print("initClient: ready. please initialize the player manager")
	return true

func disconnectPlayer(netID: int):
	peer.disconnect_peer(netID)
	map.handleLeave(netID)

func getUniqueNick(nick: String) -> String:
	var newName = nick
	var dupNum = 1
	while map.players.values().map(func(p): return p.i.nickname).has(newName):
		#print("bot named '%s' already exists, giving duplicate name" % bot.nickname)
		newName = "%s (%d)" % [nick, dupNum]
		dupNum += 1
	return newName

func runCmd(cmd: String):
	map.console.runCmd(cmd)

func shutDown():
	for p in map.players.values():
		disconnectPlayer(p)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

@rpc("any_peer", "call_remote")
func cPlayerJoin(p: PlayerInfo):
	var id: int = multiplayer.get_remote_sender_id()
	var teamMembers = map.countTeamMembers()
	p.nickname = getUniqueNick(p.nickname)
	# respect preference if team players are equal, otherwise join team with less players
	p.isYellow = p.isYellow if teamMembers.x == teamMembers.y else teamMembers.x > teamMembers.y
	p.netID = id
	map.handleJoin(p)
@rpc("any_peer", "call_remote")
func cPlayerLeave():
	var id: int = multiplayer.get_remote_sender_id()
	disconnectPlayer(id)
	#printerr("cPlayerLeave: wtf player %d does not exist????? oh well ignoring" % id)
@rpc("any_peer", "call_remote")
func cPlayerGetInfo():
	var id: int = multiplayer.get_remote_sender_id()
	sCBPlayerGetInfo.rpc_id(id, map.players[id].i)
@rpc("any_peer", "call_remote")
func cPlayerApplyInput(inputs: PlayerInputs):
	var id: int = multiplayer.get_remote_sender_id()
	map.players[id].inp = inputs
@rpc("any_peer", "call_remote")
func cGetMapInfo():
	sCBGetMapInfo.rpc_id(multiplayer.get_remote_sender_id(), map.generateInfo())
@rpc("any_peer", "call_remote")
func cGetServerSummary() -> MapSummary:
	return map.generateSummary()
@rpc("any_peer", "call_remote")
func cTryConsoleCmd(cmd: String) -> bool:
	if multiplayer.is_server():
		runCmd(cmd)
		return true
	return false

@rpc("authority", "call_local")
func sOnGoal(goalIsYellow: bool):
	if goalIsYellow: pMgr.mapInfo.currentPScore += 1
	else: pMgr.mapInfo.currentYScore += 1
	pMgr.hud.get_node("goallabel").label_settings.font_color = Color(0.5, 0, 1) if goalIsYellow else Color(1, 1, 0)
	pMgr.hud.get_node("AnimationPlayer").play("goal")
	pMgr.player.updateScores()
@rpc("authority", "call_local")
func sGiveAllPlayerInfo(i: Dictionary[int, PlayerInfo]):
	for id in i.keys():
		if not pMgr.otherPlayers.has(id) and pMgr.player.i.netID != id:
			pMgr.handleNewPlayer(i[id])
@rpc("authority", "call_local")
func sApplyPlayerLeave(id: int):
	pMgr.handlePlayerLeave(id)

@rpc("authority", "call_local")
func sCBPlayerGetInfo(i: PlayerInfo):
	pMgr.player.i = i
@rpc("authority", "call_local")
func sCBGetMapInfo(i: MapInfo):
	pMgr.mapInfo = i
@rpc("authority", "call_local")
func sCBGetMapSumm(i: MapSummary):
	pMgr.mapSumm = i
