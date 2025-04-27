class_name DeckManager extends Node


#region Constants

const BASE_CARD = preload("uid://ddi8j3e2qifws")

#endregion

#region Signals

signal CardsDealt

#endregion

#region Exports

@export var Hand : HandController
@export var HandLimit : int

#endregion

#region Public Variables

var Player : PlayerController
var PlayerDeck : Array[BaseCard] = []
var CurrentHand : Array[BaseCard] = []
var Discard : Array[BaseCard] = []

#endregion

#region Initialization

func _ready() -> void:
	Dispatch.DealCardsToPlayer.connect(deal_card_to_hand)
	Dispatch.DiscardCard.connect(discard_card)

#endregion

#region Create Deck

func create_deck() -> void:
	for s in range(0,4):
		for r in range(1, 14):
			var card : BaseCard = BASE_CARD.instantiate() as BaseCard
			Hand.DeckHolder.add_child(card)
			card.init_card(r, s)
			PlayerDeck.push_back(card)
			Dispatch.UpdateDeckCount.emit(PlayerDeck.size())
	
	PlayerDeck.shuffle()

#endregion

#region Dealing Cards

func deal_card_to_hand(number_of_cards : int) -> void:
	if Global.CurrentState != Global.GameState.IN_GAME:
		return
	
	if PlayerDeck.size() < number_of_cards:
		recycle_discard()
	
	var cardsDealt : int = 0
	for n in range(number_of_cards + 1):
		if CurrentHand.size() < HandLimit:
			var card : BaseCard = PlayerDeck.pop_front()
			CurrentHand.append(card)
			card.change_state(BaseCard.CardState.HAND)
			await Hand.add_card(card)
			cardsDealt += 1
			Dispatch.UpdateDeckCount.emit(PlayerDeck.size())
			await get_tree().create_timer(0.01).timeout
	
	CardsDealt.emit()
	send_update("{x} cards dealt.".format({"x": cardsDealt}))

#endregion

#region Playing Cards

func remove_cards_from_hand(cards : Array[BaseCard]) -> void:
	for card: BaseCard in cards:
		card.change_state(BaseCard.CardState.PLAYED)
		CurrentHand.erase(card)




func add_card_back_to_hand(card : BaseCard) -> void:
	CurrentHand.append(card)
	card.change_state(BaseCard.CardState.HAND)


#endregion

#region Discarding Cards

func discard_card(card : BaseCard) -> void:
	send_update("Discarding " + card.Name)
	card.change_state(BaseCard.CardState.DISCARDED)
	if CurrentHand.has(card):
		CurrentHand.erase(card)
	Discard.push_back(card)
	Dispatch.UpdateDiscardCount.emit(Discard.size())
	Hand.discard_card(card)
	
	send_update("Discarded 1 card.")
	await get_tree().process_frame
	await deal_card_to_hand(1)


func discard_selected_cards(cards : Array[BaseCard]) -> void:
	var cardsToDeal : int = cards.size()
	
	var cardsDiscarded : int = 0
	for card:BaseCard in cards:
		card.change_state(BaseCard.CardState.DISCARDED)
		if CurrentHand.has(card):
			CurrentHand.erase(card)
		Discard.push_back(card)
		Dispatch.UpdateDiscardCount.emit(Discard.size())
		cardsDiscarded += 1
	
	Hand.discard_cards(cards)
	
	send_update("Discarded " + str(cardsDiscarded) + " cards.")
	await get_tree().process_frame
	await deal_card_to_hand(cardsToDeal)

#endregion

#region Recycling Discard

func recycle_discard() -> void:
	for card:BaseCard in Discard:
		PlayerDeck.push_back(card)
		card.change_state(BaseCard.CardState.DECK)
		card.reparent(Hand.DeckHolder)
		Dispatch.UpdateDeckCount.emit(PlayerDeck.size())
	PlayerDeck.shuffle()
	Discard.clear()
	Dispatch.UpdateDiscardCount.emit(Discard.size())
	Dispatch.DeckReshuffled.emit()

#endregion

#region On End of Round

func discard_hand() -> void:
	for card: BaseCard in CurrentHand:
		Discard.push_back(card)
		card.change_state(BaseCard.CardState.DISCARDED)
		Hand.discard_card(card)
		Dispatch.UpdateDiscardCount.emit(Discard.size())
	CurrentHand.clear()

#endregion

#region Aesthetics



#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[1].to_html(false)
	print_rich("[color=#"+color+"]DM: " + update + "[/color]")

#endregion
