extends Resource

class_name Settoing # <-- yes this is a phighting reference. yes it is an intentional typo

# PLAYER
@export var rotMod: float = 0.05
@export var useAltPan: bool = false
@export var nickname: String = "Player"
@export var masterVolume: float = 0.5
@export var mainMenuTrack: int = 0

static var activeInstance: Settoing

static func saveToFile(s: Settoing):
	ResourceSaver.save(s, "settings.tres")

static func loadFromFile() -> Settoing:
	return ResourceLoader.load("settings.tres")
