extends Window

var net: NetInterface

func _ready() -> void:
	var l = ConsoleLogger.new()
	l.uiLog = %conlog
	OS.add_logger(l)

func _on_conprompt_text_submitted(new_text: String) -> void:
	%conprompt.text = ""
	#runCmd(new_text)
	%conlog.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	%conlog.add_text("> " + new_text)
	%conlog.pop()
	net.cTryConsoleCmd(new_text)
	%conprompt.grab_focus()
