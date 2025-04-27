class_name HUDController extends Control


#region Exports

@export_group("Labels")
@export var LevelLabel : Label
@export var TimeLabel : Label
@export var MovesLabel : Label
@export var ScoreLabel : Label
@export var DeckLabel : Label
@export var DiscardLabel : Label

@export_group("Buttons")
@export var SortButtons : HBoxContainer
@export var ActionButtons : HBoxContainer

#endregion

#region Private Variables

var Moves : int : set = set_moves
var fake_moves : int : set = set_fake_moves
var movesTween : Tween
var Score : int : set = set_score
var fake_score : int : set = set_fake_score
var scoreTween : Tween

#endregion

#region Initialization

func _ready() -> void:
	subscribe_to_signals()
	hide_all_buttons()


func subscribe_to_signals() -> void:
	Dispatch.UpdateLevel.connect(update_level)
	Dispatch.UpdateGameTime.connect(update_time)
	Dispatch.UpdateMoves.connect(update_moves)
	Dispatch.UpdateScore.connect(update_score)
	Dispatch.UpdateDeckCount.connect(update_deck)
	Dispatch.UpdateDiscardCount.connect(update_discard)

#endregion

#region Button Presses

func on_sort_by_suit_button_pressed() -> void:
	Dispatch.SortCardsBySuit.emit()


func on_sort_by_rank_button_pressed() -> void:
	Dispatch.SortCardsByRank.emit()


func on_play_cards_button_pressed() -> void:
	Dispatch.PlaySelectedCards.emit()


func on_discard_cards_button_pressed() -> void:
	Dispatch.DiscardSelectedCards.emit()


func on_pause_button_pressed() -> void:
	get_tree().paused = true
	GUI.show_pause_menu()

#endregion

#region Stat Label Methods

func update_level(newLevel : int) -> void:
	LevelLabel.text = str(newLevel)


func update_time(newTime : int) -> void:
	TimeLabel.text = Util.formatted_game_time(newTime)


func update_moves(moves : int) -> void:
	Moves = moves


func update_score(score : int)-> void:
	Score = score


func update_deck(count : int) -> void:
	DeckLabel.text = str(count)


func update_discard(count : int) -> void:
	DiscardLabel.text = str(count)

#endregion

#region Hide Buttons

func show_sort_buttons() -> void:
	SortButtons.show()


func hide_sort_buttons() -> void:
	SortButtons.show()


func show_action_buttons() -> void:
	ActionButtons.show()


func hide_action_buttons() -> void:
	ActionButtons.hide()


func show_all_buttons() -> void:
	show_sort_buttons()
	show_action_buttons()


func hide_all_buttons() -> void:
	hide_sort_buttons()
	hide_action_buttons()

#endregion

#region Updating Numbers

func set_moves(value : int) -> void:
	Moves = value
	
	if movesTween:
		movesTween.kill()
	
	movesTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	movesTween.tween_property(self, "fake_moves", Moves, 1.0)
	await movesTween.finished
	movesTween = null


func set_fake_moves(value : int) -> void:
	fake_moves = value
	MovesLabel.text = str(fake_moves)


func set_score(value : int) -> void:
	Score = value
	
	if scoreTween:
		scoreTween.kill()
	
	scoreTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	scoreTween.tween_property(self, "fake_score", Score, 1.0)
	await scoreTween.finished
	scoreTween = null


func set_fake_score(value : int) -> void:
	fake_score = value
	ScoreLabel.text = str(fake_score)

#endregion

#region Debugging TODO: Delete Later!



#endregion
