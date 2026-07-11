extends Window

var map: Map

var allCommands: Dictionary[String, Dictionary] = {
	"map": {
		
	}
}

class ConsoleLogger extends Logger:
	var uiLog: RichTextLabel
	func _log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
		uiLog.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
		uiLog.push_fgcolor(Color.YELLOW if error_type == ERROR_TYPE_WARNING else Color.RED)
		uiLog.add_text("[%s] %s: %s (%s at %s:%d)" % [Time.get_time_string_from_system(), "WARN" if error_type == ERROR_TYPE_WARNING else "ERROR", rationale, code, file, code])
		uiLog.pop()
		uiLog.pop()

	func _log_message(message: String, error: bool) -> void:
		uiLog.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
		uiLog.add_text("[INFO] " + message)
		uiLog.pop()

func runCmd(cmd: String):
	%conlog.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	%conlog.add_text("> " + cmd)
	%conlog.pop()

	var ln = cmd.split(" ")
	if ln.size() < 0: return
	if ln.size() == 1:
		printerr("no actual command specified")
		return
	var category: Dictionary[String, Callable] = allCommands.get(ln[0])
	if category == null:
		printerr("category %s not found" + ln[0])
		return
	var actualCmd: Callable = category.get(ln[1])

func _ready() -> void:
	var l = ConsoleLogger.new()
	l.uiLog = %conlog
	OS.add_logger(l)

func _on_close_requested() -> void:
	hide()

func _on_conprompt_text_submitted(new_text: String) -> void:
	%conprompt.text = ""
	runCmd(new_text)
