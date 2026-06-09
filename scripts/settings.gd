extends Resource

class_name Settoing # <-- yes this is a phighting reference. yes it is an intentional typo

# GAME INFO CONSTS
const GAME_VER = "0.2.1"
const GAME_DEMO_NUM = 2

# PLAYER
@export var rotMod: float = 0.05
@export var useAltPan: bool = false

# TEST VALUES
@export var a: String = "sdjhsjdhs"
@export var b: Array = []
@export var c: int = 69

static var activeInstance: Settoing

static func saveToFile(s: Settoing):
	ResourceSaver.save(s, "settings.tres")

static func loadFromFile() -> Settoing:
	return ResourceLoader.load("settings.tres")
