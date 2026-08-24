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

## initializes a game server on the specified port. returns true if the server is ready, false if it couldn't be created
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

## initializes a game client and attempts to connect to the specified port and ip. returns false if the client couldn't be created, true if it could
## (note that a true value does not necessarily mean the client connected successfully)
func initClient(port: int = DEFAULT_SERVER_PORT, ip: String = "127.0.0.1") -> bool:
	print("initClient: creating client")
	peer = ENetMultiplayerPeer.new()
	var result = peer.create_client(ip, port)
	if result != OK:
		printerr("initClient: could not create client: %s" % result)
		return false
	multiplayer.multiplayer_peer = peer
	print("initClient: ready. please initialize the player manager")
	return true

## disconnects the specified network id from the server and leaves from the specified map
func disconnectPlayer(netID: int):
	peer.disconnect_peer(netID)
	map.handleLeave(netID)

## checks if the specified nickname is already used by a player in the server. if it isn't, returns what was specified.
## however, if it is, adds a number in brackets that counts how many duplicates. like on windows.
## e.g. a player with the nickname "John Doe" connects to the server, but a player with the same nickname has already joined,
## so the second player gets assigned the nickname "John Doe (1)". another player with the nickname "John Doe" joins,
## so they get assigned "John Doe (2)", so on and so forth
func getUniqueNick(nick: String) -> String:
	var newName = nick
	var dupNum = 1
	while map.players.values().map(func(p): return p.i.nickname).has(newName):
		#print("bot named '%s' already exists, giving duplicate name" % bot.nickname)
		newName = "%s (%d)" % [nick, dupNum]
		dupNum += 1
	return newName

## runs the specified command on the map's console
func runCmd(cmd: String):
	map.console.runCmd(cmd)

## disconnects all players and shuts off the peer
func shutDown():
	for p in map.players.values():
		disconnectPlayer(p)
	multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()

## joins the server by sending the client's player info to the server. to receive the player's validated identity, call cPlayerGetInfo
@rpc("any_peer", "call_remote")
func cPlayerJoin(p: PlayerInfo):
	var id: int = multiplayer.get_remote_sender_id()
	var teamMembers = map.countTeamMembers()
	p.nickname = getUniqueNick(p.nickname)
	# respect preference if team players are equal, otherwise join team with less players
	p.isYellow = p.isYellow if teamMembers.x == teamMembers.y else teamMembers.x > teamMembers.y
	p.netID = id
	map.handleJoin(p)
## leaves the server and disconnects the client
@rpc("any_peer", "call_remote")
func cPlayerLeave():
	var id: int = multiplayer.get_remote_sender_id()
	disconnectPlayer(id)
	#printerr("cPlayerLeave: wtf player %d does not exist????? oh well ignoring" % id)
## gets the client's player info and calls sCBPlayerGetInfo with it
@rpc("any_peer", "call_remote")
func cPlayerGetInfo():
	var id: int = multiplayer.get_remote_sender_id()
	sCBPlayerGetInfo.rpc_id(id, map.players[id].i)
## applies the specified inputs for the player
@rpc("any_peer", "call_remote")
func cPlayerApplyInput(inputs: PlayerInputs):
	var id: int = multiplayer.get_remote_sender_id()
	map.players[id].inp = inputs
## gets the map info. callback: sCBGetMapInfo
@rpc("any_peer", "call_remote")
func cGetMapInfo():
	sCBGetMapInfo.rpc_id(multiplayer.get_remote_sender_id(), map.generateInfo())
## gets the server/map summary. callback: sCBGetServerSummary
@rpc("any_peer", "call_remote")
func cGetServerSummary():
	sCBGetServerSummary.rpc_id(multiplayer.get_remote_sender_id(), map.generateSummary())
## tries to execute the specified command. will only work if called by the server or an admin
@rpc("any_peer", "call_remote")
func cTryConsoleCmd(cmd: String):
	if multiplayer.is_server():
		runCmd(cmd)

## plays the goal animation with the specified team color
@rpc("authority", "call_local")
func sOnGoal(goalIsYellow: bool):
	if goalIsYellow: pMgr.mapInfo.currentPScore += 1
	else: pMgr.mapInfo.currentYScore += 1
	pMgr.hud.get_node("goallabel").label_settings.font_color = Color(0.5, 0, 1) if goalIsYellow else Color(1, 1, 0)
	pMgr.hud.get_node("AnimationPlayer").play("goal")
	pMgr.player.updateScores()
## gets the info of all other players and if they're not assigned in the player manager's other player list, handles them like if they just joined
@rpc("authority", "call_local")
func sGiveAllPlayerInfo(i: Dictionary[int, PlayerInfo]):
	for id in i.keys():
		if not pMgr.otherPlayers.has(id) and pMgr.player.i.netID != id:
			pMgr.handleNewPlayer(i[id])
## leaves the server
@rpc("authority", "call_local")
func sApplyPlayerLeave(id: int):
	pMgr.handlePlayerLeave(id)

## callback for cPlayerGetInfo. assigns to the player info that the player manager is managing
@rpc("authority", "call_local")
func sCBPlayerGetInfo(i: PlayerInfo):
	pMgr.player.i = i
## callback for cGetMapInfo. assigns it to the player manager's map info
@rpc("authority", "call_local")
func sCBGetMapInfo(i: MapInfo):
	pMgr.mapInfo = i
## callback for cGetServerSummary. assigns it to the player manager's map summary
@rpc("authority", "call_local")
func sCBGetServerSummary(i: MapSummary):
	pMgr.mapSumm = i
