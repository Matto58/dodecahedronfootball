extends Resource

class_name Soundtrack

@export var title: String
@export var artist: String
@export var trackURL: String
@export var artistURL: String
@export var license: String

@export var stream: AudioStreamMP3

static func create(title: String, artist: String, trackURL: String, artistURL: String, license: String, pathToMP3: String) -> Soundtrack:
	var s: Soundtrack = Soundtrack.new()
	s.title = title
	s.artist = artist
	s.trackURL = trackURL
	s.artistURL = artistURL
	s.license = license
	s.stream = AudioStreamMP3.load_from_file(pathToMP3)
	return s
