extends Node

class_name Console

var map: Map

var allCommands: Dictionary[String, Dictionary] = {
	"map": {
		"add_time": (func(args):
			if args.size() < 3:
				printerr("missing seconds")
				return
			var secs = int(args[2])
			map.roundTimer.start(map.roundTimer.time_left + secs)),
		"spawn_bot": (func(args: Array[String]):
			if args.size() < 3:
				printerr("missing isYellow")
				return
			var botSpawner: ClankerSpawner = map.get_node("clanker spawner")
			var spawnedBot = botSpawner.spawn(1, args[2] == "true", "" if args.size() < 4 else " ".join(args.slice(3)))[0]
			map.initBot(spawnedBot)),
		"spawn_bots": (func(args: Array[String]):
			if args.size() < 3:
				printerr("missing count and isYellow")
				return
			if args.size() < 4:
				printerr("missing isYellow")
				return
			var botSpawner: ClankerSpawner = map.get_node("clanker spawner")
			var count = int(args[2])
			var bots = botSpawner.spawn(count, args[3] == "true")
			for b in bots:
				map.initBot(b)),
		"kick_bot": (func(args):
			if args.size() < 3:
				printerr("missing nickname")
				return
			var nickname = " ".join(args.slice(2))
			var botSpawner: ClankerSpawner = map.get_node("clanker spawner")
			var bot = botSpawner.get_node_or_null("AI '%s'" % nickname)
			if bot == null:
				printerr("bot '%s' not found" % nickname)
				return
			botSpawner.remove_child(bot)
			bot.queue_free()
			print("kicked " + nickname)),
	}
}
var commandsHelp: Dictionary[String, String] = {
	"map add_time": "[seconds] adds seconds to the timer",
	"map spawn_bot": "[isYellow true/false] <name> spawns a bot with a given name (random if missing) into the given team",
	"map spawn_bots": "[count] [isYellow true/false] spawns multiple bots with random names into the given team",
	"map kick_bot": "[nickname] kicks the specified bot",
}

func runCmd(cmd: String):
	%conlog.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	%conlog.add_text("> " + cmd)
	%conlog.pop()

	var ln = cmd.split(" ")
	if ln.size() < 0: return
	if ln[0] == "help":
		print("all commands - [required] <optional>")
		for cat in allCommands.keys():
			print("- %s:" % cat)
			for cmdName in allCommands[cat].keys():
				var helpMsg = commandsHelp[cat + " " + cmdName]
				print("\t- %s: %s" % [cmdName, "(no help message)" if helpMsg == null else helpMsg])
		return
	if ln.size() == 1:
		printerr("no actual command specified (you specified only a category, you have to specify a category as well as a command)")
		return
	var category = allCommands.get(ln[0])
	if category == null:
		printerr("category %s not found" % ln[0])
		return
	var actualCmd = category.get(ln[1])
	actualCmd.call(ln)

func _ready() -> void:
	var l = ConsoleLogger.new()
	l.uiLog = %conlog
	OS.add_logger(l)
