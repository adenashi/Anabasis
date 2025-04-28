extends Node


#region Enums

enum GameState {
	IDLE,
	STARTING,
	IN_GAME,
	INTERSTAGE,
	ENDING
}

#endregion

#region Public Variables

var CurrentState : GameState
var StartingHealth : int = 100
var StartingDefense : int = 50
var StagesToClear : int = 1

var FreeDiscards : int = 3
var ExtraCardBonus : int = 25

var FinalTime : int
var FinalMoves : int
var FinalScore : int

#endregion

#region Initialization

func _ready() -> void:
	send_update("Loading saved data...")
	SaveData.load_data()

#endregion

#region Housekeeping Methods

func change_state(newState : GameState) -> void:
	match CurrentState:
		GameState.IDLE:
			AM.cross_fade_ambience("Menus")
		GameState.STARTING:
			AM.cross_fade_ambience("Starting")
		GameState.IN_GAME:
			AM.cross_fade_ambience("DarkCave")
		GameState.INTERSTAGE:
			AM.cross_fade_ambience("Moving")
		GameState.ENDING:
			AM.cross_fade_ambience("Surface")

func save_data() -> void:
	send_update("Saving...")
	SaveData.save_data()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_data()


func quit_game() -> void:
	save_data()
	get_tree().quit()

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : = Util.COLORS.colors[0]
	print_rich("[color=#"+str(color)+"]GLOBAL: " + update + "[/color]")

#endregion
