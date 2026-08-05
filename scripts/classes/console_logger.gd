extends Logger

class_name ConsoleLogger

var uiLog: RichTextLabel
func _log_error(function: String, file: String, line: int, code: String, rationale: String, editor_notify: bool, error_type: int, script_backtraces: Array[ScriptBacktrace]) -> void:
	if uiLog == null: return
	uiLog.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	uiLog.push_color(Color.YELLOW if error_type == ERROR_TYPE_WARNING else Color.RED)
	uiLog.add_text("[%s] %s: %s (%s at %s:%d)" % [Time.get_time_string_from_system(), "WARN" if error_type == ERROR_TYPE_WARNING else "ERROR", rationale, code, file, code])
	uiLog.pop()
	uiLog.pop()

func _log_message(message: String, error: bool) -> void:
	if uiLog == null: return
	uiLog.push_paragraph(HORIZONTAL_ALIGNMENT_LEFT)
	uiLog.push_color(Color.RED if error else Color.LIGHT_SLATE_GRAY)
	uiLog.add_text("[%s] %s" % ["ERROR" if error else "INFO", message])
	uiLog.pop()
	uiLog.pop()
