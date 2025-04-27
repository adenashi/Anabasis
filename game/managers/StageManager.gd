class_name StageManager extends Node


#region Signals

signal ReadyToBeginStage
signal ReadyToRetry
signal NextStage

#endregion

#region Exports

@export var Placard : StagePlacard

#endregion

#region Private Variables

var currentStage : int = -1

#endregion

#region Initialization

func _ready() -> void:
	Dispatch.PlaceEnemy.connect(place_enemy)
	Placard.ContinueToStage.connect(signal_begin_stage)
	Placard.RetryStage.connect(on_retry_button_pressed)
	Placard.GoToNextStage.connect(on_next_stage_button_pressed)

#endregion

#region Life Cycle Functions

func _process(_delta : float) -> void:
	pass

#endregion

#region Input Event Functions

func on_next_stage_button_pressed() -> void:
	await Placard.lower()
	NextStage.emit()


func on_retry_button_pressed() -> void:
	await Placard.lower()
	ReadyToRetry.emit()

#endregion

#region Gameplay Functions

func go_to_next_stage() -> void:
	currentStage += 1
	if currentStage >= Global.StagesToClear:
		Dispatch.AllStagesCleared.emit()
		return
	
	Dispatch.SpawnNewEnemy.emit()


func place_enemy(enemy : EnemyData) -> void:
	Placard.on_next_enemy(enemy)


func signal_begin_stage() -> void:
	await Placard.lower()
	ReadyToBeginStage.emit()


func show_stage_results(results : Dictionary) -> void:
	Placard.on_stage_cleared(results)


#endregion

#region Aesthetics



#endregion

#region Debugging TODO: Delete Later!



#endregion
