class_name GameOver extends Node


#region Exports

@export_group("Labels")
@export var StagesResult : Label
@export var TimeResult : Label
@export var ReshufflesResult : Label
@export var ScoreResult : Label

@export_subgroup("Record")
@export var MostClearedGroup : HBoxContainer
@export var MostCleared : Label
@export var TimeRecordGroup : HBoxContainer
@export var BestTime : Label
@export var ReshufflesRecordGroup : HBoxContainer
@export var BestReshuffles : Label
@export var ScoreRecordGroup : HBoxContainer
@export var HighScore : Label

#endregion

#region Private Variables

var GameStages : int
var fake_stages : int : set = set_fake_stages
var GameTime : int
var fake_time : int : set = set_fake_time
var Reshuffles : int
var fake_reshuffles : int : set = set_fake_reshuffles
var Score : int
var fake_score : int : set = set_fake_score

#endregion

#region Initialization

func _ready() -> void:
	update_results()

#endregion

#region Button Methods

func on_main_menu_button_pressed() -> void:
	GUI.Transitioner.transition_to_main_menu()


func on_new_game_button_pressed() -> void:
	GUI.Transitioner.transition_to_new_game()

#endregion

#region Results Methods

func update_results()-> void:
	await set_stages(Global.StagesToClear)
	var mostCleared : int = SaveData.get_most_stages_cleared()
	if mostCleared < Global.StagesToClear:
		MostCleared.text = str(Global.StagesToClear)
		MostClearedGroup.show()
	else:
		MostClearedGroup.hide()
	
	var record : Dictionary = SaveData.RecordsByStages[Global.StagesToClear]
	
	await set_time(Global.FinalTime)
	
	if record.BestTime > 0:
		BestTime.text = Util.formatted_game_time(record.BestTime)
		TimeRecordGroup.show()
	else:
		TimeRecordGroup.hide()
	
	await set_reshuffles(Global.FinalMoves)
	
	if record.BestReshuffles >= 0:
		BestReshuffles.text = str(record.BestReshuffles)
		ReshufflesRecordGroup.show()
	else:
		ReshufflesRecordGroup.hide()
	
	await set_score(Global.FinalScore)
	
	if record.HighScore > 0:
		HighScore.text = str(record.HighScore) 
		ScoreRecordGroup.show()
	else:
		ScoreRecordGroup.hide()


#endregion

#region Aesthetics

func set_stages(value : int) -> void:
	GameStages = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_stages", GameStages, 0.35)
	await tween.finished


func set_fake_stages(value : int) -> void:
	fake_stages = value
	StagesResult.text = str(fake_stages)


func set_time(value : int) -> void:
	GameTime = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_time", GameTime, 0.7)
	await tween.finished


func set_fake_time(value : int) -> void:
	fake_time = value
	TimeResult.text = Util.formatted_game_time(fake_time)


func set_reshuffles(value : int) -> void:
	Reshuffles = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_reshuffles", Reshuffles, 0.35)
	await tween.finished


func set_fake_reshuffles(value : int) -> void:
	fake_reshuffles = value
	ReshufflesResult.text = str(fake_reshuffles)


func set_score(value : int) -> void:
	Score = value
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "fake_score", Score, 1.0)
	await tween.finished


func set_fake_score(value : int) -> void:
	fake_score = value
	ScoreResult.text = str(fake_score)

#endregion

#region Debugging TODO: Delete Later!



#endregion
