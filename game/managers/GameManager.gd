class_name GM extends Node


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

var CurrentLevel : int
var GameTime : int
var GameReshuffles : int = 0
var GameScore : int = 0

#endregion

#region Private Variables

var waitingForTutorial : bool = true

var TotalGameTime : int
var TotalReshuffles : int
var TotalScore : int

var playerWon : bool

#endregion

#region Initialization

func _ready() -> void:
	subscribe_to_signals()
	Combat.Deck = Deck
	Combat.CurrentEnemy = CurrentEnemy
	CurrentEnemy.EnemyDied.connect(Combat.on_enemy_died)
	Combat.Player = Player
	Deck.Player = Player
	Validator.Deck = Deck
	Validator.Combat = Combat
	start_game()
	await one_frame()
	start_level()


func subscribe_to_signals() -> void:
	GameTimer.timeout.connect(update_time)
	Dispatch.PlaceEnemy.connect(on_enemy_placed)
	Dispatch.ReadyToStartFirstStage.connect(on_tutorial_ready)
	Dispatch.PlayerDied.connect(on_player_died)
	Dispatch.EnemyDied.connect(initiate_next_level)
	Dispatch.AddPoints.connect(update_score)
	Dispatch.DeckReshuffled.connect(update_moves)
	Stage.ReadyToBeginStage.connect(on_ready_to_start_stage)
	Stage.ReadyToRetry.connect(reenter_combat_mode)
	Stage.NextStage.connect(start_level)
	Dispatch.AllStagesCleared.connect(on_player_won)

#endregion

#region Gameplay Functions

#region New Game

func start_game() -> void:
	Global.CurrentState = Global.GameState.STARTING
	Deck.create_deck()
	Player.set_stats(Global.StartingHealth, Global.StartingDefense)

#endregion

#region New Level

func start_level() -> void:
	Stage.go_to_next_stage()


func start_game_timers() -> void:
	GameTimer.wait_time = 1.0
	GameTimer.one_shot = false
	GameTimer.start()


func on_enemy_placed(data : EnemyData) -> void:
	CurrentLevel += 1
	Dispatch.UpdateLevel.emit(CurrentLevel)
	CurrentEnemy.init_enemy(data)


func on_tutorial_ready() -> void:
	waitingForTutorial = false


func on_ready_to_start_stage() -> void:
	if CurrentLevel == 1 and SaveData.TutorialOn:
		Dispatch.FirstStageReached.emit()
		while waitingForTutorial:
			await one_frame()
	
	Global.CurrentState = Global.GameState.IN_GAME
	Player.update_max_defense(Global.StartingDefense + (10*CurrentLevel))
	Player.restore_to_full_health()
	HUD.show()
	Deck.deal_card_to_hand(9)
	await Deck.CardsDealt
	HUD.show_all_buttons()
	start_game_timers()
	Combat.start_combat()

#endregion

#region End of Level 

func initiate_next_level() -> void:
	Global.CurrentState = Global.GameState.INTERSTAGE
	Dispatch.AddPoints.emit(CurrentEnemy.Data.PointValue)
	HUD.hide_all_buttons()
	GameTimer.stop()
	Deck.discard_hand()
	HUD.hide()
	playerWon = true
	await one_frame()
	
	if CurrentLevel < Global.StagesToClear:
		var results : Dictionary = {
			"Stage": CurrentLevel,
			"Time": GameTime,
			"Reshuffles": GameReshuffles,
			"Score": GameScore,
			"Enemy": CurrentEnemy,
			"Result": "Victory"
		}
		Stage.show_stage_results(results)
		update_culmulative_results()
	else:
		update_culmulative_results()
		on_player_won()


func update_culmulative_results() -> void:
	TotalGameTime += GameTime
	TotalReshuffles += GameReshuffles
	TotalScore += GameScore
	
	GameTime = 0
	GameReshuffles = 0
	GameScore = 0

#endregion

#region End of Game

func on_player_died() -> void:
	Global.CurrentState = Global.GameState.INTERSTAGE
	GameTimer.stop()
	HUD.hide_all_buttons()
	Deck.discard_hand()
	HUD.hide()
	
	var results : Dictionary = {
		"Time": GameTime,
		"Reshuffles": GameReshuffles,
		"Score": GameScore,
		"Enemy": CurrentEnemy,
		"Result": "Defeat"
	}
	Stage.show_stage_results(results)
	update_culmulative_results()
	playerWon = false


func on_retry_level() -> void:
	reenter_combat_mode()


func reenter_combat_mode() -> void:
	HUD.show()
	if !playerWon:
		CurrentEnemy.reset_stats()
		CurrentEnemy.reset_hud()
		Player.set_stats(Global.StartingHealth, Global.StartingDefense)
		Global.CurrentState = Global.GameState.IN_GAME
		Deck.recycle_discard()

		Deck.deal_card_to_hand(9)
		await Deck.CardsDealt
		HUD.show_all_buttons()
		start_game_timers()
		Combat.start_combat()
	else:
		Global.CurrentState = Global.GameState.INTERSTAGE
		Stage.go_to_next_stage()


func on_player_won() -> void:
	Global.CurrentState = Global.GameState.ENDING
	update_final_results()
	GUI.Transitioner.transition_to_victory()


func update_final_results() -> void:
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

#endregion

#region Stat Keeping

func update_time() -> void:
	GameTime += 1
	Dispatch.UpdateGameTime.emit(GameTime)


func update_moves() -> void:
	GameReshuffles += 1
	Dispatch.UpdateMoves.emit(GameReshuffles)


func update_score(points : int) -> void:
	GameScore += points
	Player.CurrentPoints += points
	Dispatch.UpdateScore.emit(GameScore)

#endregion

#region Timing Control

func one_frame() -> void:
	await get_tree().process_frame

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[5].to_html(false)
	print_rich("[color=#"+color+"]GM: " + update + "[/color]")

#endregion
