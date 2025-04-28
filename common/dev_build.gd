extends Control

#region Exports

@export_group("Bug Report Panel")
@export var BugReportPanel : PanelContainer
@export var ScreenPhaseLabel : Label

#endregion

#region Initialization

func _ready() -> void:
	BugReportPanel.hide()

#endregion

#region Input Event Functions

func on_report_bug_button_pressed() -> void:
	var currentScreen : String = get_tree().current_scene.name
	currentScreen = currentScreen.replace("@", "_")
	var currentPhase : String = Global.GameState.keys()[Global.CurrentState].capitalize()
	var reportHeader : String = currentScreen + " | " + currentPhase
	ScreenPhaseLabel.text = reportHeader
	reportHeader += "\n"
	DisplayServer.clipboard_set(reportHeader)
	BugReportPanel.show()


func on_submit_report_button_pressed() -> void:
	BugReportPanel.hide()
	if OS.has_feature('JavaScript'):
		JavaScriptBridge.eval("""
			window.open('https://discord.gg/xy7b3VS3yx', '_blank').focus();
		""")
	else:
		OS.shell_open("https://discord.gg/7wWvNf59t3")

#endregion

#region Debugging TODO: Delete Later!



#endregion
