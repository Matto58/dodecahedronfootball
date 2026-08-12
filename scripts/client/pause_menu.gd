extends Control

var mapInterpreter: Node3D

func _on_button_pressed() -> void:
	hide()

func _on_button_2_pressed() -> void:
	$PanelContainer/HBoxContainer/settoing.visible = not $PanelContainer/HBoxContainer/settoing.visible

func _on_button_4_pressed() -> void:
	DHMain.ask(self,
		"are you sure", "are you sure",
		"pretty sure", "nah",
		mapInterpreter.imOuttaHere, func(): pass).popup_centered_clamped()

func _on_visibility_changed() -> void:
	if visible:
		$PanelContainer/HBoxContainer/VBoxContainer/Button.grab_focus()
