class_name PlayValidator extends Node

#region Enums

enum ActionType {
	NONE,
	DEFENSE,
	ATTACK
}

#endregion

#region Exports

@export var Camera : Camera3D

#endregion

#region Public Variables

var Deck : DeckManager
var Combat : CombatManager

#endregion

#region Private Variables

var selectedCards : Array[BaseCard] = []
var sigilTween : Tween

#endregion

#region Initialization

func _ready() -> void:
	Dispatch.CardSelected.connect(on_card_selected)
	Dispatch.CardDeselected.connect(on_card_deselected)
	Dispatch.PlaySelectedCards.connect(on_play_selected_cards)
	Dispatch.DiscardSelectedCards.connect(on_discard_selected_cards)
	Dispatch.EndPlayerTurn.connect(clear_selected_cards)

#endregion

#region Selecting and Deselecting Cards

func on_card_selected(card : BaseCard) -> void:
	if selectedCards.has(card):
		return
	
	selectedCards.append(card)
	if selectedCards.size() >= 3:
		if valid_run():
			for c in selectedCards:
				c.show_action(ActionType.DEFENSE)
			if SaveData.TutorialOn:
				Dispatch.RunSelected.emit()
		elif valid_full_sequence():
			var att : int = 0
			for c in selectedCards:
				c.show_action(ActionType.ATTACK)
				att += c.Value
			Dispatch.UpdatePlayerAttack.emit(att)
			if SaveData.TutorialOn:
				Dispatch.SequenceSelected.emit()
		elif valid_partial_sequence():
			var att : int = 0
			for c in selectedCards:
				c.show_action(ActionType.ATTACK)
				att += c.Value
			Dispatch.UpdatePlayerAttack.emit(att)
			if SaveData.TutorialOn:
				Dispatch.SequenceSelected.emit()
		else:
			for c in selectedCards:
				c.show_action(ActionType.NONE)
			if SaveData.TutorialOn:
				Dispatch.InvalidCardsSelected.emit()


func on_card_deselected(card : BaseCard) -> void:
	selectedCards.erase(card)
	if selectedCards.size() < 3:
		for c in selectedCards:
				c.show_action(ActionType.NONE)
	else:
		if valid_run():
			for c in selectedCards:
				c.show_action(ActionType.DEFENSE)
		elif valid_full_sequence():
			var att : int = 0
			for c in selectedCards:
				c.show_action(ActionType.ATTACK)
				att += c.Value
			Dispatch.UpdatePlayerAttack.emit(att)
		elif valid_partial_sequence():
			var att : int = 0
			for c in selectedCards:
				c.show_action(ActionType.ATTACK)
				att += c.Value
			Dispatch.UpdatePlayerAttack.emit(att)
		else:
			if SaveData.TutorialOn:
				Dispatch.InvalidCardsSelected.emit()
			Dispatch.UpdatePlayerAttack.emit(0)


func on_discard_selected_cards() -> void:
	await Deck.discard_selected_cards(selectedCards)
	await one_frame()
	send_update("Clearing Selected Cards Array.")
	selectedCards.clear()


func on_play_selected_cards() -> void:
	if selectedCards.size() < 3:
		return
	
	Deck.remove_cards_from_hand(selectedCards)
	await one_frame()
	check_selected_cards()


func clear_selected_cards() -> void:
	await one_frame()
	send_update("Clearing Selected Cards Array.")
	selectedCards.clear()


#endregion

#region Checking for Runs and Sequences

func check_selected_cards() -> void:
	selectedCards.sort_custom(Util.sort_by_suit)
	var message : String
	if valid_run():
		message = "Valid Defense Run played: "
		for card:BaseCard in selectedCards:
			message += card.Name + " "
		send_update(message)
		send_defense()
		Dispatch.PlayerMove.emit()
	elif valid_full_sequence():
		message = "Valid Full Sequence played: "
		for card:BaseCard in selectedCards:
			message += card.Name + " "
		send_update(message)
		send_both()
		Dispatch.PlayerMove.emit()
	elif valid_partial_sequence():
		message = "Valid Attack Sequence played: "
		for card:BaseCard in selectedCards:
			message += card.Name + " "
		send_update(message)
		if SaveData.TutorialOn:
			Dispatch.PlayerAttacked.emit()
		send_attack()
		Dispatch.PlayerMove.emit()
	else:
		message = "Not a valid run or sequence: "
		for card:BaseCard in selectedCards:
			message += card.Name + " "
			Deck.add_card_back_to_hand(card)
		send_update(message)
		Dispatch.StartEnemyTurn.emit()


## Checks if the selected cards are all of the same value.
func valid_run() -> bool: # Valid runs are added to Defense
	var value : int = selectedCards.front().Value
	for card:BaseCard in selectedCards:
		if card.Value != value:
			return false
	
	return true


## Checks if the selected cards are all of the same suit, and are of sequential values
func valid_full_sequence() -> bool: # Valid sequences are Attacks
	var suit : BaseCard.CardSuit = selectedCards.front().Suit
	for card:BaseCard in selectedCards:
		if card.Suit != suit:
			return false
	
	return valid_partial_sequence()


func valid_partial_sequence() -> bool:
	selectedCards.sort_custom(Util.sort_by_rank)
	var start : int = selectedCards.front().Value
	for i in range(1, selectedCards.size()):
		start += 1
		if selectedCards[i].Value != start:
			return false
	
	return true

#endregion

#region Updating Attack and Defense

func send_attack() -> void:
	for card:BaseCard in selectedCards:
			card.change_state(BaseCard.CardState.PLAYED)
	Dispatch.PerformAttack.emit(selectedCards)


func send_defense() -> void:
	for card:BaseCard in selectedCards:
			card.change_state(BaseCard.CardState.PLAYED)
	Dispatch.AddDefense.emit(selectedCards)


func send_both() -> void:
	for card:BaseCard in selectedCards:
			card.change_state(BaseCard.CardState.PLAYED)
	Dispatch.DoAttackAndDefense.emit(selectedCards)

#endregion

#region Timing Control

func one_frame() -> void:
	await get_tree().process_frame

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[2].to_html(false)
	print_rich("[color=#"+color+"]PV: " + update + "[/color]")

#endregion
