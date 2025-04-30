class_name AGM extends Node


#region Enums

enum StageResult {
	DEFEAT,
	VICTORY
}

#endregion

#region Exports

@export var Validator : PlayValidator
@export var Combat : CombatManager
@export var Deck : DeckManager
@export var Stage : StageManager
@export var CurrentEnemy : BaseEnemy
@export var Player : PlayerController
@export var GameTimer : Timer
@export var HUD : HUDController

#endregion

#region Public Variables

var CurrentStage : int = 0
var GameTime : int = 0
var GameReshuffles : int = 0
var GameScore : int = 0

#endregion

#region Private Variables

var waitingForTutorial : bool

var currentMaxDefense : int
var currentEnemyDefenseAward : int
var discardsSinceLastPlay : int = 0
var stageResult : StageResult

var TotalGameTime : int
var TotalReshuffles : int
var TotalScore : int

#endregion

#region Initialization

func _ready() -> void:
	Global.NextStage = 1
	subscribe_to_dispatch_signals()
	subscribe_to_stage_signals()
	set_references()
	start_new_game()
	
	if OS.has_feature("editor"):
		Debug.GameManager = self


func subscribe_to_dispatch_signals() -> void:
	Dispatch.PlaceEnemy.connect(set_new_enemy_data)
	Dispatch.ReadyToStartFirstStage.connect(on_tutorial_first_step_completed)
	Dispatch.DiscardSelectedCards.connect(on_player_discarded_cards)
	Dispatch.PlayerMove.connect(reset_discard_counter)
	Dispatch.PlayerDied.connect(on_player_lost_stage)
	Dispatch.EnemyDied.connect(on_player_cleared_stage)
	Dispatch.AddPoints.connect(on_score_increased)
	Dispatch.DeckReshuffled.connect(on_deck_reshuffled)
	Dispatch.AllStagesCleared.connect(on_player_cleared_all_stages)
	send_update("Subscribed to Dispatch signals.")


func subscribe_to_stage_signals() -> void:
	Stage.ReadyToBeginStage.connect(on_ready_to_start_stage)
	Stage.ReadyToRetry.connect(restart_current_stage)
	Stage.NextStage.connect(continue_to_next_stage)
	send_update("Subscribed to Stage signals.")


func set_references() -> void:
	Combat.Deck = Deck
	Combat.CurrentEnemy = CurrentEnemy
	CurrentEnemy.EnemyDied.connect(Combat.on_enemy_died)
	Combat.Player = Player
	Combat.Field.Player = Player
	Combat.Field.Enemy = CurrentEnemy
	Deck.Player = Player
	Validator.Deck = Deck
	Validator.Combat = Combat
	CurrentEnemy.Deck = Deck
	send_update("Set manager references.")

#endregion

#region Gameplay Functions

func change_global_state(newState : Global.GameState) -> void:
	Global.change_state(newState)

#region Starting New Game

func start_new_game() -> void:
	send_update("Starting new game.")
	await one_frame()
	change_global_state(Global.GameState.STARTING)
	waitingForTutorial = SaveData.TutorialOn
	create_deck()
	await one_frame()
	show_next_stage()

#endregion

#region Starting a New Stage

func on_ready_to_start_stage() -> void:
	initialize_player_stats()
	show_hud()
	Deck.CanDeal = true
	await deal_hand()
	start_player_turn()


func start_player_turn() -> void:
	if CurrentStage == 0 and waitingForTutorial:
		send_update("Waiting for tutorial signal.")
		Dispatch.FirstStageReached.emit()
		while waitingForTutorial:
			await one_frame()
	
	start_new_stage()


#region Tutorial Signals

func on_tutorial_first_step_completed() -> void:
	waitingForTutorial = false

#endregion


func start_new_stage() -> void:
	update_current_stage()
	update_player_stats()
	send_update("Starting Stage " + str(CurrentStage))
	change_global_state(Global.GameState.IN_GAME)
	start_game_timer()

#endregion

#region Retrying Current Stage

func restart_current_stage() -> void:
	send_update("Restarting Stage " + str(CurrentStage))
	reset_game_stats()
	show_hud()
	reset_current_enemy_stats()
	reset_player_stats()
	change_global_state(Global.GameState.IN_GAME)
	Deck.CanDeal = true
	await deal_hand()
	start_game_timer()

#endregion

#region Continuing to Next Stage

func continue_to_next_stage() -> void:
	send_update("Moving to next stage.")
	change_global_state(Global.GameState.STARTING)
	show_next_stage()

#endregion

#region Updating Stats

func update_current_stage() -> void:
	reset_game_stats()
	CurrentStage += 1
	Dispatch.UpdateLevel.emit(CurrentStage)
	Global.NextStage += 1


func on_game_timer_timeout() -> void:
	GameTime += 1
	Dispatch.UpdateGameTime.emit(GameTime)


func reset_discard_counter() -> void:
	discardsSinceLastPlay = 0


func on_score_increased(amount : int) -> void:
	GameScore += amount
	Player.CurrentPoints += amount
	Dispatch.UpdateScore.emit(GameScore)


func on_deck_reshuffled() -> void:
	if Global.CurrentState == Global.GameState.INTERSTAGE:
		return
	GameReshuffles += 1
	Dispatch.UpdateMoves.emit(GameReshuffles)


func on_player_discarded_cards() -> void:
	if Global.CurrentState != Global.GameState.IN_GAME:
		return
	
	discardsSinceLastPlay += 1
	if discardsSinceLastPlay >= Global.FreeDiscards:
		CurrentEnemy.perform_action()
		reset_discard_counter()


func current_stage_results() -> Dictionary:
	var results : Dictionary = {
		"Stage": CurrentStage,
		"Time": GameTime,
		"Reshuffles": GameReshuffles,
		"Score": GameScore,
		"Enemy": CurrentEnemy,
		"Result": StageResult.keys()[stageResult].capitalize()
	}
	
	return results


func reset_game_stats() -> void:
	send_update("Resetting game stats.")
	GameTime = 0
	Dispatch.UpdateGameTime.emit(GameTime)
	GameReshuffles = 0
	Dispatch.UpdateMoves.emit(GameReshuffles)
	GameScore = 0
	Dispatch.UpdateScore.emit(GameScore)

#endregion

#region Ending a Stage

func on_player_cleared_stage() -> void:
	stop_game_timer()
	on_score_increased(CurrentEnemy.Data.PointValue)
	change_global_state(Global.GameState.INTERSTAGE)
	stageResult = StageResult.VICTORY
	send_update("Stage " + str(CurrentStage) + " cleared.")
	await one_frame()
	
	await reset_all_cards()
	await hide_hud()
	await one_frame()
	
	if CurrentStage < Global.StagesToClear:
		show_stage_results()
	else:
		on_player_cleared_all_stages()


func on_player_lost_stage() -> void:
	stop_game_timer()
	change_global_state(Global.GameState.INTERSTAGE)
	stageResult = StageResult.DEFEAT
	send_update("Stage " + str(CurrentStage) + " failed.")
	await one_frame()
	
	await reset_all_cards()
	await hide_hud()
	await one_frame()
	
	show_stage_results()


func update_cumulative_stats() -> void:
	TotalGameTime += GameTime
	TotalReshuffles += GameReshuffles
	TotalScore += GameScore

#endregion

#region Ending the Game

func on_player_cleared_all_stages() -> void:
	send_update("All stages cleared.")
	change_global_state(Global.GameState.ENDING)
	update_cumulative_stats()
	update_final_game_stats()
	go_to_game_over_scene()


func update_final_game_stats() -> void:
	Global.FinalTime = TotalGameTime
	Global.FinalMoves = TotalReshuffles
	Global.FinalScore = TotalScore
	
	var record = SaveData.RecordsByStages[Global.StagesToClear]
	
	if record.BestTime == 0 or (record.BestTime > 0 and Global.FinalTime < record.BestTime):
		record.BestTime = Global.FinalTime
	if record.BestReshuffles == -1 or (record.BestReshuffles > -1 and Global.FinalMoves < record.BestReshuffles):
		record.BestReshuffles = Global.FinalMoves
	if record.HighScore == 0 or (record.HighScore > 0 and Global.FinalScore > record.HighScore):
		record.HighScore = Global.FinalScore

#endregion

#region Card Commands

func create_deck() -> void:
	Deck.create_deck()


func deal_hand() -> void:
	await Deck.deal_card_to_hand(Deck.HandLimit)


func reset_all_cards() -> void:
	await Validator.on_discard_selected_cards()
	Deck.discard_hand()
	Deck.recycle_discard()
	send_update("All cards returned to deck.")

#endregion

#region Stage Commands

func show_next_stage() -> void:
	AM.play_sfx("Transition", "NewStage")
	Stage.go_to_next_stage()


func show_stage_results() -> void:
	var sound : String = "PlayerWon" if stageResult == StageResult.VICTORY else "PlayerLost"
	AM.play_sfx("Transition", sound)
	Stage.show_stage_results(current_stage_results())
	update_cumulative_stats()

#endregion

#region Current Enemy Commands

func set_new_enemy_data(data : EnemyData) -> void:
	send_update("Setting new enemy.")
	CurrentEnemy.init_enemy(data)
	CurrentEnemy.IsDead = false


func reset_current_enemy_stats() -> void:
	CurrentEnemy.reset_stats()
	CurrentEnemy.reset_hud()

#endregion

#region Player Commands

func initialize_player_stats() -> void:
	currentMaxDefense = Global.StartingDefense
	Player.MaxHealth = Global.StartingHealth
	Player.MaxDefense = currentMaxDefense
	reset_player_stats()


func update_player_stats() -> void:
	send_update("Updating Player Defense")
	currentMaxDefense += currentEnemyDefenseAward
	Player.MaxDefense = currentMaxDefense
	reset_player_stats()
	currentEnemyDefenseAward = CurrentEnemy.Data.PointValue / 100


func reset_player_stats() -> void:
	Player.restore_to_full_health()
	Player.restore_full_defense()

#endregion

#region Game Timer Commands

func start_game_timer() -> void:
	GameTimer.wait_time = 1.0
	GameTimer.one_shot = false
	GameTimer.timeout.connect(on_game_timer_timeout)
	GameTimer.start()
	Combat.start_combat()


func stop_game_timer() -> void:
	GameTimer.stop()
	if GameTimer.timeout.is_connected(on_game_timer_timeout):
		GameTimer.timeout.disconnect(on_game_timer_timeout)

#endregion

#region HUD Commands

func show_hud() -> void:
	HUD.show()
	await wait_for(1.0)
	HUD.show_all_buttons()


func hide_hud() -> void:
	HUD.hide_all_buttons()
	await wait_for(1.0)
	HUD.hide()

#endregion

#region Scene Transitions

func go_to_game_over_scene() -> void:
	AM.play_sfx("Transition", "PlayerWon")
	GUI.Transitioner.transition_to_victory()

#endregion

#endregion

#region Timing Control

func one_frame() -> void:
	await get_tree().process_frame


func wait_for(seconds : float) -> void:
	await get_tree().create_timer(seconds).timeout

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[5].to_html(false)
	print_rich("[color=#"+color+"]GM: " + update + "[/color]")

#endregion
