extends Node

class_name MusicManager

static var mainMenuTracks: Array[Soundtrack] = [
	Soundtrack.create("GR00ves in that motherbOARd of m1Ne", "kala Kiso", "https://matto58.bandcamp.com/track/gr00ves-in-that-motherboard-of-m1ne", "https://matto58.bandcamp.com", "CC BY-SA 4.0", "res://music/main_menu/gr00ves.mp3"),
	Soundtrack.create("Our Brand New Product™", "kala Kiso", "https://matto58.bandcamp.com/track/our-brand-new-product", "https://matto58.bandcamp.com", "CC BY-SA 4.0", "res://music/main_menu/product.mp3"),
	Soundtrack.create("Logermengemowse", "kala Kiso", "https://matto58.bandcamp.com/track/logermengemowse", "https://matto58.bandcamp.com", "CC BY-SA 4.0", "res://music/main_menu/logermengemowse.mp3"),
	Soundtrack.create("Interface", "kala Kiso", "https://matto58.bandcamp.com/track/interface", "https://matto58.bandcamp.com", "CC BY-SA 4.0", "res://music/main_menu/interface.mp3"),
	Soundtrack.create("Local Detective", "kala Kiso", "https://matto58.bandcamp.com/track/local-detective", "https://matto58.bandcamp.com", "CC BY-SA 4.0", "res://music/main_menu/detective.mp3"),
	Soundtrack.create("Mechanopolis", "kala Kiso", "https://matto58.bandcamp.com/track/mechanopolis", "https://matto58.bandcamp.com", "CC BY-SA 4.0", "res://music/main_menu/mechanopolis.mp3"),
	Soundtrack.create("The Unparalleled Silliness of Petting a Cat (Mgaow!)", "kala Kiso", "https://matto58.bandcamp.com/track/the-unparalleled-silliness-of-petting-a-cat-mgaow", "https://matto58.bandcamp.com", "CC BY-SA 4.0", "res://music/main_menu/mgaow.mp3"),
	Soundtrack.create("Furnace For The Wicked", "kala Kiso", "", "https://matto58.bandcamp.com", "CC BY-SA 4.0", "res://music/main_menu/furnace.mp3")
]
var currentlyPlaying: Soundtrack
var currentlyPlayingInx: int
@export var tracks: Array[Soundtrack] = []
@export var useMainMenuOST: bool = false
@export var audioPlayer: AudioStreamPlayer

signal onNewTrackSelected(track: Soundtrack)

func selectRandomTrack() -> Soundtrack:
	var newTrack: int = -1
	while newTrack == currentlyPlayingInx or newTrack == -1:
		newTrack = randi_range(0, (mainMenuTracks if useMainMenuOST else tracks).size()-1)
	return selectTrackFromIndex(newTrack)

func selectTrackFromIndex(index: int) -> Soundtrack:
	currentlyPlayingInx = index
	currentlyPlaying = (mainMenuTracks if useMainMenuOST else tracks)[index]
	onNewTrackSelected.emit(currentlyPlaying)
	audioPlayer.stream = currentlyPlaying.stream
	audioPlayer.play()
	return currentlyPlaying

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audioPlayer.finished.connect(selectRandomTrack)
	if audioPlayer.stream != null:
		audioPlayer.volume_linear = Settoing.activeInstance.masterVolume
