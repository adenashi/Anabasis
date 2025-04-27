class_name GUIManager extends CanvasLayer


#region Signals

signal HidingSettings

#endregion

#region Exports

@export_group("Menus")
@export var PauseMenu : Control
@export var SettingsMenu : Control
@export var ConfirmWindow : ConfirmationPopup

@export_group("Transitioner")
@export var Transitioner : SceneTransitioner

@export var DevUI : Control

#endregion

#region Private Variables

var settingsTween : Tween

#endregion

#region Input Event Functions

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
	
		if get_tree().paused:
			show_pause_menu()
		else:
			hide_pause_menu()

#endregion

#region Menu Functions

func show_pause_menu() -> void:
	Transitioner.transition_to_menu(PauseMenu)


func hide_pause_menu() -> void:
	Transitioner.transition_from_menu(PauseMenu)


func show_settings() -> void:
	SettingsMenu.show()
	if settingsTween:
		settingsTween.kill()
	
	settingsTween = SettingsMenu.create_tween()
	settingsTween.tween_property(SettingsMenu, "modulate:a", 1.0, 0.5)
	await settingsTween.finished
	settingsTween = null


func hide_settings() -> void:
	if settingsTween:
		settingsTween.kill()
	
	settingsTween = SettingsMenu.create_tween()
	settingsTween.tween_property(SettingsMenu, "modulate:a", 0.0, 0.5)
	await settingsTween.finished
	settingsTween = null
	HidingSettings.emit()
	SettingsMenu.hide()


func show_new_game_confirmation() -> void:
	ConfirmWindow.get_confirmation("Start New Game", "All progress and points will be lost. Are you sure?", on_new_game_confirmed, hide_confirmer, "New Game", "Back")


func on_new_game_confirmed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		PauseMenu.hide()
	await Transitioner.fade_out()
	#await hide_confirmer()
	ConfirmWindow.hide()
	Transitioner.transition_to_new_game()


func show_main_menu_confirmation() -> void:
	ConfirmWindow.get_confirmation("Quit To Main Menu", "All progress and points will be lost. Are you sure?", on_main_menu_confirmed, hide_confirmer, "Main Menu", "Back")


func on_main_menu_confirmed() -> void:
	if get_tree().paused:
		get_tree().paused = false
		PauseMenu.hide()
	await Transitioner.fade_out()
	#await hide_confirmer()
	ConfirmWindow.hide()
	Transitioner.transition_to_main_menu()


func show_exit_game_confirmation() -> void:
	ConfirmWindow.get_confirmation("Exit Game", "Are you sure?", on_exit_confirmed, hide_confirmer, "Exit", "Cancel")


func on_exit_confirmed() -> void:
	Global.quit_game()


func hide_confirmer() -> void:
	await Transitioner.transition_from_menu(ConfirmWindow)


#endregion


#region Debugging TODO: Delete Later!



#endregion
