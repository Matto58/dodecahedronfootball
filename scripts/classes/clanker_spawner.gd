extends Node3D

class_name ClankerSpawner

var m: Map

# tf2 style
# todo: come up with more that aren't as corny
static var botNames: Array[String] = [
	"ilo moli", # "death machine" in toki pona - also a palindrome, fun fact
	"B33PB00P",
	"Only A Robor :(",
	"I am a robot", # funny captcha reference
	"Creature of Steel", # ultakil
	"No Foot Only Ballin'", # i'm gonna fucking explode what did i write
	"010001110110000101111001", # me
	"crouton.net",
	"tenor.com gif picker",
	"Han-Tyumi", # king gizzard
	"Gilgamesh", # giiiiiiiilgamesh
	"Maurice", # also ultakil
	"Gila Monster", # watch me. i can do multiple king gizzard references
	"Dragon", # because they also like perfectly normal and fuckin' badass names
	"N.G.R.I.", # ...okay maybe not that one but sure
]

## creates `count` bots, assigns them all the username specified and moves them to their respective team's spawnpoints, while also making them children of this node
## if `username` is blank, then gives a random username to each one
## returns the array of spawned bots if successfully spawned, otherwise an empty array if something went wrong
## spawned bots will by default have no valid target nodes and their AITargets will be None. it is the job of the script calling this function to assign the targets 
func spawn(count: int, onYellowSide: bool, nickname: String = "", easyDiff: bool = true) -> Array[Clanker]:
	if m.spawnpointsPurple == null or m.spawnpointsYellow == null:
		printerr("cannot spawn bots: neither team's spawnpoints are valid")
		return []
	var spawnpoints: Array[Vector4] = (m.spawnpointsYellow if onYellowSide else m.spawnpointsPurple).duplicate()
	if count > spawnpoints.size():
		printerr("cannot spawn bots: tried to spawn %d bots on a map with %d spawnpoints for the %s side" % [count, spawnpoints.size(), "yellow" if onYellowSide else "purple"])
		return []
	if count < 0:
		printerr("cannot spawn %d bots. seriously wtf were you thinking" % count)
		return []

	var spawnedBots: Array[Clanker] = []
	for i in range(count):
		var bot = createBot(onYellowSide, easyDiff)
		if not nickname.is_empty(): bot.nickname = m.getUniqueNick(nickname)

		add_child(bot)
		spawnedBots.append(bot)

		var spInx = randi_range(0, spawnpoints.size()-1)
		var sp = spawnpoints[spInx]
		spawnpoints.remove_at(spInx)
		bot.global_position = Vector3(sp.x, sp.y, sp.z)
		bot.global_rotation_degrees = Vector3(0.0, sp.w, 0.0)

		print("spawned %s bot '%s' at %s" % ["yellow" if bot.isYellow else "purple", bot.nickname, bot.global_position])
	return spawnedBots

## creates a bot with a random nickname on the specified team and with the specified difficulty
static func createBot(isYellow: bool, easyDiff: bool) -> Clanker:
	var bot = Clanker.new()
	bot.isYellow = isYellow
	bot.isEasyDifficulty = easyDiff
	bot.nickname = botNames.pick_random()

	var coll = CollisionShape3D.new()
	coll.name = "CollisionShape3D"
	coll.shape = preload("res://misc/player_collision.tres")
	bot.add_child(coll)
	var mesh = MeshInstance3D.new()
	mesh.name = "MeshInstance3D"
	mesh.mesh = preload("res://misc/player_mesh.tres").duplicate()
	bot.add_child(mesh)
	return bot
