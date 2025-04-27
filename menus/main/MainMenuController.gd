class_name MainMenuController extends Control


#region Constants

const FADE_SPEED : float = 1.0

#endregion

#region Exports

@export_group("Pages")
## The container that holds the main buttons and are faded in and out on
## transtion.
@export var MainScreen : Control
@export var RecordsScreen : Control
@export var CreditsScreen : Control
@export var ExitScreen : Control
@export var GameStart : GameStarter


@export_group("Records")
@export var BestTimeLabels : Array[Label] = []
@export var ReshuffleLabels : Array[Label] = []
@export var HighScoreLabels : Array[Label] = []
@export var Confirmation : ConfirmationPopup

#region Asi

@export_group("Asi")
@export var Asi : TextureRect
@export var LightShaft : PointLight2D

#endregion

#endregion

#region Private Variables

## A tween used to switch between screens on the Main Menu, and to fade in the 
## main buttons when the Main Menu is initially loaded.
var switchTween : Tween

#endregion

#region Initialization

func _ready() -> void:
	MainScreen.modulate.a = 0.0
	CreditsScreen.modulate.a = 0.0
	show_records()
	fade_in_main_menu()

#endregion

#region Input Event Functions

## Calls the GUIManager to transition to the game scene.
func on_play_button_pressed() -> void:
	fade_out_main_menu()
	GameStart.show()
	GameStart.move_asi()


## Calls the GUIManager to show the Settings Menu.
func on_settings_button_pressed() -> void:
	fade_out_main_menu()
	GUI.HidingSettings.connect(on_back_from_settings)
	GUI.show_settings()


func on_back_from_settings() -> void:
	fade_in_main_menu()
	GUI.HidingSettings.disconnect(on_back_from_settings)


## Calls [method switch_screens] to switch from the Main Menu screen to the Credits screen.
func on_credits_button_pressed() -> void:
	switch_screens(MainScreen, CreditsScreen)


## Calls [method switch_screens] to switch from the Credits screen to the Main Menu screen.
func on_back_from_credits_button_pressed() -> void:
	switch_screens(CreditsScreen, MainScreen)


## Calls [method switch_screens] to switch from the Main Menu screen to the Records screen.
func on_records_button_pressed() -> void:
	switch_screens(MainScreen, RecordsScreen)


func on_delete_records_button_pressed() -> void:
	Confirmation.get_confirmation("Delete Records", "Once deleted, they will not be recoverable. Are you sure you want to delete your records?", on_delete_records_confirmed, Confirmation.hide)


func on_delete_records_confirmed() -> void:
	SaveData.clear_records()
	switch_screens(RecordsScreen, MainScreen)


## Calls [method switch_screens] to switch from the Records screen to the Main Menu screen.
func on_back_from_records_button_pressed() -> void:
	switch_screens(RecordsScreen, MainScreen)


## Calls the Global Autoload to quit the game.
func on_exit_button_pressed() -> void:
	switch_screens(MainScreen, ExitScreen)


## Called when the Cancel button is pressed on the exit screen.
func on_cancel_exit_button_pressed() -> void:
	switch_screens(ExitScreen, MainScreen)


## Called when the Confirm button is pressed on the Exit screen.
func on_confirm_exit_button_pressed() -> void:
	Global.quit_game()

#endregion

#region Aesthetics

## Fades in the [param MainScreen] to show the Main Menu buttons.
func fade_in_main_menu() -> void:
	reset_tween()
	switchTween.tween_property(MainScreen, "modulate:a", 1.0, FADE_SPEED)
	await switchTween.finished
	switchTween = null


func fade_out_main_menu() -> void:
	reset_tween()
	switchTween.tween_property(MainScreen, "modulate:a", 0.0, FADE_SPEED)
	await switchTween.finished
	switchTween = null


func switch_screens(currentScreen : Control, newScreen) -> void:
	reset_tween()
	switchTween.tween_property(currentScreen, "modulate:a", 0.0, FADE_SPEED)
	currentScreen.hide()
	
	newScreen.show()
	switchTween = create_tween()
	switchTween.tween_property(newScreen, "modulate:a", 1.0, FADE_SPEED)
	await switchTween.finished
	switchTween = null


func reset_tween() -> void:
	if switchTween:
		switchTween.kill()
	
	switchTween = create_tween()

#endregion

#region Showing Records

func show_records() -> void:
	var keys = SaveData.RecordsByStages.keys()
	
	var bestTimeIndex : int = -1
	var bestTime : int = 100000
	var bestReshufIndex : int = -1
	var bestReshuf : int = 100000
	var bestScoreIndex : int = -1
	var bestScore : int = 0
	
	for i in range(keys.size()):
		var record : Dictionary = SaveData.RecordsByStages[keys[i]]
		if record.BestTime != 0 and record.BestTime < bestTime:
			bestTimeIndex = i
			bestTime = record.BestTime
		BestTimeLabels[i].text = Util.formatted_game_time(record.BestTime) if record.BestTime > 0 else "--"
		
		if record.BestReshuffles != -1 and record.BestReshuffles < bestReshuf:
			bestReshufIndex = i
			bestReshuf = record.BestReshuffles
		ReshuffleLabels[i].text = str(record.BestReshuffles) if record.BestReshuffles > -1 else "--"
		
		if record.HighScore > 0 and record.HighScore > bestScore:
			bestScoreIndex = i
			bestScore = record.HighScore
		HighScoreLabels[i].text = str(record.HighScore) if record.HighScore > 0 else "--"
	
	BestTimeLabels[bestTimeIndex].add_theme_font_size_override("font_size", 21)
	BestTimeLabels[bestTimeIndex].get_parent_control().get_child(0).add_theme_font_size_override("font_size", 21)
	
	ReshuffleLabels[bestReshufIndex].add_theme_font_size_override("font_size", 21)
	ReshuffleLabels[bestReshufIndex].get_parent_control().get_child(0).add_theme_font_size_override("font_size", 21)
	
	HighScoreLabels[bestScoreIndex].add_theme_font_size_override("font_size", 21)
	HighScoreLabels[bestScoreIndex].get_parent_control().get_child(0).add_theme_font_size_override("font_size", 21)

#endregion

#region Debugging TODO: Delete Later!



#endregion
