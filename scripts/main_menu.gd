extends Control

const MAP_IDS = ["testmap", null]
var loadedMap: Map

func switchToLoadedMap():
	var pb = %purplebotsbox.value if $HBoxContainer/PanelContainer3.visible else 0
	var yb = %yellowbotsbox.value if $HBoxContainer/PanelContainer3.visible else 0
	var yello = randf() >= 0.5 if %randteam.button_pressed or not $HBoxContainer/PanelContainer3.visible else %yteam.button_pressed
	loadedMap.purpleBots = pb
	loadedMap.yellowBots = yb
	loadedMap.mainPlayerIsYellow = yello
	if not $HBoxContainer/PanelContainer3.visible:
		loadedMap.roundTimer.wait_time = 10800.0
	get_tree().change_scene_to_node(loadedMap)

func changeToMap(mapPathOrName: String, builtIn: bool = true):
	$loadingscreen.size = Vector2(get_window().size)
	$loadingscreen/Label2.size = $loadingscreen.size
	$loadingscreen.show()
	var mapScene: PackedScene = MapLoader.loadBuiltinMap(mapPathOrName) if builtIn else MapLoader.loadCustomMap(mapPathOrName)
	if mapScene == null:
		$loadingscreen.hide()
		var p = ConfirmationDialog.new()
		p.title = "Error!"
		p.dialog_text = "Failed to load the map."
		add_child(p)
		p.popup_centered_clamped()
		return

	loadedMap = mapScene.instantiate()
	$loadingscreen.hide()
	if not MapLoader.validateMap(loadedMap):
		var p = ConfirmationDialog.new()
		p.max_size = get_window().size * .75
		p.title = "Error!"
		p.dialog_text = "The loaded map (%s by %s) is invalid, but can be played.\nHowever, attempting to play it WILL lead to errors and possibly the game crashing.\nKnowing this, would you like to play it anyway?" % [loadedMap.title, loadedMap.author]
		p.ok_button_text = "Yes, I know what I'm doing"
		p.cancel_button_text = "No, take me back"
		p.confirmed.connect(switchToLoadedMap)
		add_child(p)
		p.popup_centered_clamped()
		p.get_cancel_button().grab_focus()
		return
	switchToLoadedMap()

func updateTrackDisplay(track):
	%nowplaying.text = "♫ Now playing: %s - %s" % [track.artist, track.title]

func _ready() -> void:
	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.hide()
	$HBoxContainer/PanelContainer3.hide()
	get_window().title = "Dodecahedron Football Demo " + str(Settoing.GAME_DEMO_NUM) + " [v" + Settoing.GAME_VER + "]"
	%democounter.text = "demo " + str(Settoing.GAME_DEMO_NUM)
	$HBoxContainer/VBoxContainer/Container/Button.grab_focus()

	$MusicManager.onNewTrackSelected.connect(updateTrackDisplay)
	if Settoing.activeInstance.mainMenuTrack != 0:
		$MusicManager.selectTrackFromIndex(Settoing.activeInstance.mainMenuTrack-1)
	else:
		$MusicManager.selectRandomTrack()
	$MusicManager.audioPlayer.volume_linear = Settoing.activeInstance.masterVolume
	$HBoxContainer/PanelContainer2/settoing.musicMgr = $MusicManager
	updateTrackDisplay($MusicManager.currentlyPlaying)

func _on_button_4_pressed() -> void:
	$HBoxContainer/PanelContainer.show()
	$HBoxContainer/PanelContainer2.hide()
	$HBoxContainer/PanelContainer3.hide()

func _on_button_2_pressed() -> void:
	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.show()
	$HBoxContainer/PanelContainer3.hide()

func _on_playmapsandbox_pressed() -> void:
	_on_maplist_item_activated(%maplist.get_selected_items()[0])

func _on_maplist_item_selected(index: int) -> void:
	%playmapsandbox.disabled = false if index == 0 else MAP_IDS[index-1] == null

func _on_maplist_item_activated(index: int) -> void:
	if index != 0:
		changeToMap(MAP_IDS[index-1], true)
		return
	%selmap.popup_file_dialog()

func _on_selmap_file_selected(path: String) -> void:
	%playmapsandbox.disabled = false
	changeToMap(path)

func _on_button_3_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.hide()
	$HBoxContainer/PanelContainer3.show()

func _on_selmapopenbtn_pressed() -> void:
	$HBoxContainer/PanelContainer.visible = not $HBoxContainer/PanelContainer.visible
