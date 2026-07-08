extends VBoxContainer

var musicMgr: MusicManager

func _ready() -> void:
	resetSettings()
	var mainMenuTrackCopyrightNotice = ""
	for t in MusicManager.mainMenuTracks:
		#print("* %s by %s (download [here](%s)) - under the %s license" % [t.title, t.artist, t.trackURL, t.license])
		%mainmenutrack.add_item(t.title + " by " + t.artist)
		mainMenuTrackCopyrightNotice += "\n- %s by %s is under the %s license - [url=\"%s\"]get this track[/url] - [url=\"%s\"]visit the artist's website[/url]" % [t.title, t.artist, t.license, t.trackURL, t.artistURL]
	%abouttext.text %= mainMenuTrackCopyrightNotice
	%versionlabel.text = "Dodecahedron Football - Version " + Settoing.GAME_VER + " - Demo " + str(Settoing.GAME_DEMO_NUM)

func resetSettings():
	# for some reason, setting it to null first is the only way for the settings to actually reset
	Settoing.activeInstance = null
	Settoing.activeInstance = Settoing.loadFromFile()
	if Settoing.activeInstance == null: Settoing.activeInstance = Settoing.new()

	%rotsensitivity.value = Settoing.activeInstance.rotMod * 100
	%rotsensitivitylabel.text = str(%rotsensitivity.value)
	%rightstickforpan.button_pressed = Settoing.activeInstance.useAltPan
	%nickname.text = Settoing.activeInstance.nickname
	%mastervol.value = Settoing.activeInstance.masterVolume * 100
	%mastervollabel.text = str(int(%mastervol.value)) + "%"
	%mainmenutrack.selected = Settoing.activeInstance.mainMenuTrack

func _on_rotationsensitivity_value_changed(value: float) -> void:
	Settoing.activeInstance.rotMod = value / 100
	%rotsensitivitylabel.text = str(value)

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	print("OPENING url " + str(meta))
	OS.shell_open(str(meta))

func _on_rightstickforpan_toggled(toggled_on: bool) -> void:
	print(toggled_on)
	Settoing.activeInstance.useAltPan = toggled_on

func _on_nickname_text_changed(new_text: String) -> void:
	Settoing.activeInstance.nickname = new_text

func _on_mastervol_value_changed(value: float) -> void:
	Settoing.activeInstance.masterVolume = value / 100
	%mastervollabel.text = str(int(value)) + "%"
	if musicMgr != null: musicMgr.audioPlayer.volume_linear = Settoing.activeInstance.masterVolume

func _on_mainmenutrack_item_selected(index: int) -> void:
	Settoing.activeInstance.mainMenuTrack = index

func _on_savesettingsbtn_pressed() -> void:
	Settoing.saveToFile(Settoing.activeInstance)

func _on_resetsettingsbtn_pressed() -> void:
	resetSettings()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
