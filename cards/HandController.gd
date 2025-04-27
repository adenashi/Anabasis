class_name HandController extends Node2D


#region Exports

@export_group("Card Holders")
@export var CardHolder : Node2D
@export var SortHolder : Node2D
@export var DeckHolder : Node2D
@export var DiscardHolder : Node2D

@export_group("Card Positioning")
@export var HandRadius : int = 1000
@export var CardAngle : float = -90.0
@export var MinimumAngle : float = -110.0
@export var MaximumAngle : float = -70.0
@export var MaximumSpread : float = 5.0
@export var SpreadCurve : Curve

@export_subgroup("In Editor Only")
@export var DebugShape : CollisionShape2D

#endregion

#region Public Variables

var CardsInHand : int

#endregion

#region Private Variables

var sorting : bool

#endregion

#region Life Cycle Functions

func _ready() -> void:
	Dispatch.MouseEnteredCard.connect(shift_away_from_hovered_card)
	Dispatch.MouseExitedCard.connect(reset_rotation)
	Dispatch.SortCardsBySuit.connect(sort_hand_by_suit)
	Dispatch.SortCardsByRank.connect(sort_hand_by_rank)
	organize_hand()

#endregion

#region Gameplay Functions

func add_card(card : BaseCard) -> void:
	card.flip_card(true)
	card.reparent(CardHolder)
	await get_tree().process_frame
	await sort_hand_by_suit()


func organize_hand() -> void:
	var angleLimit : float = abs(MinimumAngle) - abs(MaximumAngle)
	var separation : float = min(angleLimit / CardHolder.get_child_count(), MaximumSpread)
	
	var currentAngle : float = -(separation * (CardHolder.get_child_count() -1) / 2) - 90
	for i in range(CardHolder.get_child_count()):
		var angle = currentAngle
		var pos : Vector2 = get_card_position(angle)
		#CardHolder.get_child(i).update_transform(pos, (angle + 90))
		CardHolder.get_child(i).update_transform(pos, 0)
		currentAngle += separation
	
	if CardHolder.get_child_count() > 1:
		Dispatch.ShowSortButtons.emit()
	else:
		Dispatch.HideSortButtons.emit()


func sort_hand_by_suit() -> void:
	sorting = true
	
	var hand : Array[BaseCard] = []
	for child in CardHolder.get_children():
		hand.append(child as BaseCard)
		child.reparent(SortHolder)
	await get_tree().process_frame
	hand.sort_custom(Util.sort_by_rank)
	hand.sort_custom(Util.sort_by_suit)
	await get_tree().process_frame
	
	sorting = false
	for card in hand:
		card.reparent(CardHolder)


func sort_hand_by_rank() -> void:
	sorting = true
	
	var hand : Array[BaseCard] = []
	for child in CardHolder.get_children():
		hand.append(child as BaseCard)
		child.reparent(SortHolder)
	await get_tree().process_frame
	hand.sort_custom(Util.sort_by_rank)
	await get_tree().process_frame
	
	sorting = false
	for card in hand:
		card.reparent(CardHolder)


func shift_away_from_hovered_card(card : BaseCard) -> void:
	var index = card.get_index()
	if index == CardHolder.get_child_count() - 1 or index == 0:
		CardHolder.get_child(index).start_hover_effect()
		return
	
	for i in range(CardHolder.get_child_count()):
		if i == index:
			CardHolder.get_child(i).start_hover_effect()
		#else:
			#var handRatio : float = 0.5
			#if index > 0:
				#handRatio = float(i) / float(CardHolder.get_child_count())
			#if i < index:
				#CardHolder.get_child(i).update_transform(CardHolder.get_child(i).handPosition, CardHolder.get_child(i).handRotation - (MaximumSpread * 2 * (SpreadCurve.sample(handRatio))))
			#elif i > index:
				#CardHolder.get_child(i).update_transform(CardHolder.get_child(i).handPosition, CardHolder.get_child(i).handRotation + (MaximumSpread * 2 * (SpreadCurve.sample(handRatio))))


func reset_rotation(card : BaseCard) -> void:
	var index = card.get_index()
	if index == CardHolder.get_child_count() - 1 or index == 0:
		CardHolder.get_child(index).end_hover_effect()
		return
	
	for i in range(CardHolder.get_child_count()):
		if i == index:
			CardHolder.get_child(i).end_hover_effect()
		#else:
			#var handRatio : float = 0.5
			#if index > 0:
				#handRatio = float(i) / float(CardHolder.get_child_count())
			#if i < index:
				#CardHolder.get_child(i).update_transform(CardHolder.get_child(i).handPosition, CardHolder.get_child(i).handRotation + (MaximumSpread * 2 * (SpreadCurve.sample(handRatio))))
			#elif i > index:
				#CardHolder.get_child(i).update_transform(CardHolder.get_child(i).handPosition, CardHolder.get_child(i).handRotation - (MaximumSpread * 2 * (SpreadCurve.sample(handRatio))))


func reorder_hand() -> void:
	if sorting:
		return
	
	organize_hand()
	CardsInHand = CardHolder.get_child_count()


func discard_cards(cards : Array[BaseCard]) -> void:
	for card:BaseCard in cards:
		discard_card(card)
		send_update("Discarded " + card.Name + ".")


func discard_card(card : BaseCard) -> void:
	sorting = true
	card.move_to_position(DiscardHolder.global_position, 0.05)
	card.reparent(DiscardHolder)
	card.z_index = 0

#endregion

#region Aesthetics

func get_card_position(angle_in_deg : float) -> Vector2:
	var x : float = HandRadius * cos(deg_to_rad(angle_in_deg))
	var y : float = HandRadius * sin(deg_to_rad(1.0))
	
	return Vector2(int(x), int(y))

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[4].to_html(false)
	print_rich("[color=#"+color+"]HC: " + update + "[/color]")

#endregion
