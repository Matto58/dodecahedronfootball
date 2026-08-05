extends Control

func updateTrackDisplay(track):
	%nowplaying.text = "♫ Now playing: %s - %s" % [track.artist, track.title]

func _ready() -> void:
	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.hide()
	$HBoxContainer/PanelContainer3.hide()
	get_window().title = "Dodecahedron Football Demo " + str(DHMain.GAME_DEMO_NUM) + " [v" + DHMain.GAME_VER + "]"
	%democounter.text = "demo " + str(DHMain.GAME_DEMO_NUM)
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

func _on_button_3_pressed() -> void:
	get_tree().quit()

func _on_button_pressed() -> void:
	$HBoxContainer/PanelContainer.hide()
	$HBoxContainer/PanelContainer2.hide()
	$HBoxContainer/PanelContainer3.show()

func _on_selmapopenbtn_pressed() -> void:
	$HBoxContainer/PanelContainer.visible = not $HBoxContainer/PanelContainer.visible

func _on_connectbtn_pressed() -> void:
	$loadingscreen.show()
	var gameP: PackedScene = preload("res://scenes/ingame.tscn")
	var game: Node3D = gameP.instantiate()
	game.connIP = %ipinput.text
	game.connPort = %portinput.text
	game.prefYellow = randf() <= 0.5 if %prefrandteam.button_pressed else %prefyteam.button_pressed
	get_tree().change_scene_to_node(game)
