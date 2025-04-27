class_name PauseMenuController extends Control


#region Initialization

func _ready() -> void:
	pass

#endregion

#region Input Event Functions


func on_resume_game_clicked() -> void:
	get_tree().paused = false
	hide()


func on_settings_clicked() -> void:
	GUI.show_settings()


func on_new_game_clicked() -> void:
	GUI.show_new_game_confirmation()


func on_main_menu_clicked() -> void:
	GUI.show_main_menu_confirmation()

#endregion

#region Debugging TODO: Delete Later!



#endregion
