extends VBoxContainer

func _ready() -> void:
	Settoing.activeInstance = Settoing.loadFromFile()
	if Settoing.activeInstance == null: Settoing.activeInstance = Settoing.new()

	%rotsensitivity.value = Settoing.activeInstance.rotMod * 100
	%rotsensitivitylabel.text = str(%rotsensitivity.value)
	%rightstickforpan.button_pressed = Settoing.activeInstance.useAltPan
	%nickname.text = Settoing.activeInstance.nickname
	%mastervol.value = Settoing.activeInstance.masterVolume * 100
	%mastervollabel.text = str(int(%mastervol.value)) + "%"
	%versionlabel.text = "Dodecahedron Football - Version " + Settoing.GAME_VER + " - Demo " + str(Settoing.GAME_DEMO_NUM)

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

func _on_savesettingsbtn_pressed() -> void:
	Settoing.saveToFile(Settoing.activeInstance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
