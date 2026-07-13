extends Control

func _on_button_pressed() -> void:
	hide()

func _on_button_2_pressed() -> void:
	$PanelContainer/HBoxContainer/settoing.visible = not $PanelContainer/HBoxContainer/settoing.visible

func _on_button_4_pressed() -> void:
	# todo: add "are you sure" message
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_visibility_changed() -> void:
	if visible:
		$PanelContainer/HBoxContainer/VBoxContainer/Button.grab_focus()
