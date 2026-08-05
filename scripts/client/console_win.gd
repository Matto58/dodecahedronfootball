extends Window

var net: NetInterface

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_conprompt_text_submitted(new_text: String) -> void:
	%conprompt.text = ""
	#runCmd(new_text)
	net.runCmd(new_text)
	%conprompt.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
