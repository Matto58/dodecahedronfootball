extends VBoxContainer

func _ready() -> void:
	Settoing.activeInstance = Settoing.loadFromFile()
	if Settoing.activeInstance == null: Settoing.activeInstance = Settoing.new()

	%rotsensitivity.value = Settoing.activeInstance.rotMod * 100
	%rotsensitivitylabel.text = str(%rotsensitivity.value)
	%versionlabel.text = "Dodecahedron Football - Version " + Settoing.GAME_VER + " - Demo " + str(Settoing.GAME_DEMO_NUM)

func _on_rotationsensitivity_value_changed(value: float) -> void:
	Settoing.activeInstance.rotMod = value / 100
	%rotsensitivitylabel.text = str(value)

func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	print("OPENING url " + str(meta))
	OS.shell_open(str(meta))

func _on_savesettingsbtn_pressed() -> void:
	Settoing.saveToFile(Settoing.activeInstance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
