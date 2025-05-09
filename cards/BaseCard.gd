class_name BaseCard extends Node2D


#region Enums

enum CardSuit {
	HEARTS,
	CLUBS,
	DIAMONDS,
	SPADES
}

enum CardState {
	DECK,
	HAND,
	SELECTED,
	PLAYED,
	DISCARDED
}

enum StatusEffect {
	NONE,
	ATTACK,
	DEFENSE,
	COMBO,
	ACTIVE,
	ROLLING,
	HEALING,
	COOLDOWN,
	LOCKED
}

#endregion

#region Constants

const VALUES : Array[String] = ["JOKER", "A","2","3","4","5","6","7","8","9","10","J","Q","K"]
const HOVER_SCALE : float = 1.2
const HOVER_SPEED : float = 0.1
const MOVE_SPEED : float = 0.05

const ATTACK_COLOR : Color = Color(0.996, 0.388, 0.886)
const DEFENSE_COLOR : Color = Color(0.545, 1.0, 0.996)
const COMBO_COLOR : Color = Color(0.992, 0.635, 0.533)
const NORMAL_COLOR : Color = Color(1.0, 1.0, 1.0)

#endregion

#region Exports

@export_group("Controls")
@export var CardBack : Sprite2D
@export var RankLabelUpright : Label
@export var SuitIconUpright : TextureRect
@export var RankLabelReversed : Label
@export var SuitIconReversed : TextureRect
@export_group("Status", "Status")
@export var StatusIconLarge : TextureRect
@export var StatusIconSmall : TextureRect
@export var StatusLabel : Label

#endregion

#region Public Variables

#region Card Data

var Name : String
var Value : int
var Suit : CardSuit
var PointValue : int

#endregion

#region Status Variables

var CurrentState : CardState
var ShowingFace : bool
var CurrentStatus : StatusEffect
var AffectedAttack : Global.Turn
var MoveLimit : int
var MoveCounter : int

#endregion

#region Hand Positioning

var handPosition : Vector2
var handRotation : float

#endregion

#endregion

#region Private Variables

var hoverTween : Tween
var moveTween : Tween
var statusTween : Tween

#endregion

#region Initialization

func init_card(value : int, suit : int) -> void:
	Value = value
	Suit = suit as CardSuit
	var card_name : String
	
	match Value:
		1:
			card_name = "Ace of "
			PointValue = 150
		11:
			card_name = "Jack of "
			PointValue = 100
		12:
			card_name = "Queen of "
			PointValue = 100
		13:
			card_name = "King of "
			PointValue = 100
		_:
			card_name = str(Value) + " of "
			PointValue = 50
	
	card_name += CardSuit.keys()[suit].capitalize()
	Name = card_name
	
	RankLabelUpright.text = VALUES[Value]
	RankLabelReversed.text = VALUES[Value]
	var file = "res://cards/assets/suits/" + CardSuit.keys()[suit].capitalize() + "64.png"
	var img = load(file)
	SuitIconUpright.texture = img
	SuitIconReversed.texture = img
	Dispatch.PlayerMove.connect(increment_move_counter)

#endregion

#region Input Event Functions

func on_mouse_entered() -> void:
	if CurrentState == CardState.HAND:
		Dispatch.MouseEnteredCard.emit(self)


func on_mouse_exited() -> void:
	if CurrentState == CardState.HAND:
		Dispatch.MouseExitedCard.emit(self)


func on_mouse_clicked(event : InputEvent) -> void:
	if Global.CurrentTurn != Global.Turn.PLAYER:
		return
	
	match CurrentStatus:
		StatusEffect.ROLLING, StatusEffect.COOLDOWN, StatusEffect.LOCKED:
			return
	
	if event.is_action_pressed("left_click"):
		match CurrentState:
			CardState.HAND:
				change_state(CardState.SELECTED)
			CardState.SELECTED:
				change_state(CardState.HAND)

#endregion

#region Gameplay Functions

func change_state(newState : CardState) -> void:
	match CurrentState:
		CardState.HAND:
			if newState == CardState.SELECTED:
				Dispatch.CardSelected.emit(self)
				start_selected_effect()
		CardState.SELECTED:
			if newState == CardState.HAND:
				Dispatch.CardDeselected.emit(self)
				end_selected_effect()
	
	CurrentState = newState
	
	if CurrentState == CardState.DISCARDED:
		show_action(PlayValidator.ActionType.NONE)

#endregion

#region Aesthetics

#region Flip Effects

func flip_card(show_face : bool) -> void:
	ShowingFace = show_face
	CardBack.visible = !ShowingFace

#endregion

#region Movement

func update_transform(pos : Vector2, rot_in_deg : float) -> void:
	if CurrentState == CardState.SELECTED:
		return
	
	handPosition = pos
	handRotation = rot_in_deg
	
	reset_move_tween()
	moveTween.set_parallel()
	moveTween.tween_property(self, "position", handPosition, MOVE_SPEED)
	moveTween.tween_property(self, "scale", Vector2.ONE, MOVE_SPEED)
	moveTween.tween_property(self, "rotation_degrees", handRotation, MOVE_SPEED)
	await moveTween.finished
	moveTween = null


func move_to_position(destination : Vector2, speed : float) -> void:
	if hoverTween:
		hoverTween.kill()
	reset_move_tween()
	AM.play_sfx("Game", "Cards")
	moveTween.tween_property(self, "global_position", destination, speed)
	await moveTween.finished
	moveTween = null


func reset_move_tween() -> void:
	if moveTween:
		moveTween.kill()
	moveTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

#endregion

#region Hover Effects

func start_hover_effect() -> void:
	if CurrentState == CardState.SELECTED:
		return
	
	if moveTween:
		moveTween.kill()
	reset_hover_tween()
	AM.play_sfx("Game", "Cards")
	hoverTween.set_trans(Tween.TRANS_ELASTIC).set_parallel()
	hoverTween.tween_property(self, "rotation_degrees", 0.0, HOVER_SPEED)
	hoverTween.tween_property(self, "scale", Vector2.ONE * HOVER_SCALE, HOVER_SPEED)
	await hoverTween.finished
	hoverTween = null
	z_index = 100


func end_hover_effect() -> void:
	if CurrentState == CardState.SELECTED:
		return
	
	reset_hover_tween()
	hoverTween.set_trans(Tween.TRANS_ELASTIC).set_parallel()
	hoverTween.tween_property(self, "rotation_degrees", handRotation, HOVER_SPEED)
	hoverTween.tween_property(self, "scale", Vector2.ONE, HOVER_SPEED)
	await hoverTween.finished
	hoverTween = null
	z_index = 0


func reset_hover_tween() -> void:
	if hoverTween:
		hoverTween.kill()
	hoverTween = create_tween().set_ease(Tween.EASE_IN_OUT)

#endregion

#region Selected Effect

func start_selected_effect() -> void:
	position.y -= 50


func end_selected_effect() -> void:
	position.y += 50
	show_action(PlayValidator.ActionType.NONE)

#endregion

#region Action Effects

func show_action(action : PlayValidator.ActionType) -> void:
	match action:
		PlayValidator.ActionType.DEFENSE:
			RankLabelUpright.modulate = DEFENSE_COLOR
			SuitIconUpright.modulate = DEFENSE_COLOR
			RankLabelReversed.modulate = DEFENSE_COLOR
			SuitIconReversed.modulate = DEFENSE_COLOR
			apply_status_effect(StatusEffect.DEFENSE)
		PlayValidator.ActionType.ATTACK:
			RankLabelUpright.modulate = ATTACK_COLOR
			SuitIconUpright.modulate = ATTACK_COLOR
			RankLabelReversed.modulate = ATTACK_COLOR
			SuitIconReversed.modulate = ATTACK_COLOR
			apply_status_effect(StatusEffect.ATTACK)
		PlayValidator.ActionType.COMBO:
			RankLabelUpright.modulate = COMBO_COLOR
			SuitIconUpright.modulate = COMBO_COLOR
			RankLabelReversed.modulate = COMBO_COLOR
			SuitIconReversed.modulate = COMBO_COLOR
			apply_status_effect(StatusEffect.COMBO)
		PlayValidator.ActionType.NONE:
			RankLabelUpright.modulate = NORMAL_COLOR
			SuitIconUpright.modulate = NORMAL_COLOR
			RankLabelReversed.modulate = NORMAL_COLOR
			SuitIconReversed.modulate = NORMAL_COLOR
			apply_status_effect(StatusEffect.NONE)

#endregion

#region Status Effects

func apply_status_effect(effect : StatusEffect, moves : int = 0) -> void:
	match effect:
		StatusEffect.NONE:
			reset_status_effect()
		StatusEffect.ATTACK:
			show_attack_status_effect()
		StatusEffect.DEFENSE:
			show_defense_status_effect()
		StatusEffect.COMBO:
			show_combo_status_effect()
		StatusEffect.ROLLING:
			apply_rolling_status_effect()
		StatusEffect.HEALING:
			initiate_healing_effect()
		StatusEffect.COOLDOWN:
			initiate_cooldown_effect()
		StatusEffect.LOCKED:
			initiate_locked_effect(moves)


func reset_status_effect() -> void:
	CurrentStatus = StatusEffect.NONE
	StatusIconLarge.texture = null
	StatusIconSmall.texture = null
	StatusLabel.text = ""
	StatusLabel.modulate = Color.WHITE
	MoveCounter = -1
	MoveLimit = -1


func show_attack_status_effect() -> void:
	CurrentStatus = StatusEffect.ATTACK
	set_small_status_icon(ATTACK_COLOR)
	StatusLabel.text = str(Value)


func show_defense_status_effect() -> void:
	CurrentStatus = StatusEffect.DEFENSE
	set_small_status_icon(DEFENSE_COLOR)
	StatusLabel.text = str(PointValue / 10)


func show_combo_status_effect() -> void:
	CurrentStatus = StatusEffect.COMBO
	set_small_status_icon(COMBO_COLOR)
	StatusLabel.text = str(PointValue / 10)


func set_small_status_icon(mod_color : Color) -> void:
	var key = CurrentStatus
	StatusIconLarge.texture = null
	StatusIconSmall.texture = VFX.StatusIcons[key][0]
	StatusLabel.modulate = mod_color


func apply_rolling_status_effect() -> void:
	CurrentStatus = StatusEffect.ROLLING
	var results : Array[int] = await perform_roll_tween()
	var amount : int = -(PointValue / 10) * (results[1] + 1)
	match results[0]:
		0: # Defense
			Dispatch.PlayerDefenseEffect.emit(amount)
			AffectedAttack = Global.Turn.NONE
			await get_tree().create_timer(2.0).timeout
			reset_status_effect()
		1: # Attack
			Dispatch.PlayerAttackEffect.emit(amount)
			AffectedAttack = Global.Turn.PLAYER
			await get_tree().create_timer(2.0).timeout
			initiate_cooldown_effect()
		2: # Health
			AffectedAttack = Global.Turn.NONE
			await get_tree().create_timer(2.0).timeout
			initiate_healing_effect()
		3: # Enemy
			Dispatch.EnemyAttackEffect.emit(amount)
			AffectedAttack = Global.Turn.ENEMY
			await get_tree().create_timer(2.0).timeout
			initiate_cooldown_effect()


func perform_roll_tween() -> Array[int]:
	var results : Array[int] = [0,0]
	
	results[0] = await roll_die(StatusEffect.ACTIVE)
	StatusIconSmall.texture = VFX.StatusIcons[StatusEffect.ACTIVE][results[0]]
	StatusIconSmall.hide()
	
	results[1] = await roll_die(StatusEffect.ROLLING)
	await get_tree().create_timer(0.2).timeout
	StatusIconLarge.texture = null
	StatusIconSmall.show()
	StatusLabel.text = str(-(PointValue / 10) * (results[1] + 1))
	
	return results


func roll_die(dice : StatusEffect) -> int:
	var die : Array = VFX.StatusIcons[dice].duplicate()
	die.shuffle()
	var index : int = -1
	for i in 10:
		index = randi_range(0, die.size() - 1)
		var tex : Texture = die[index]
		statusTween = create_tween()
		statusTween.tween_callback(tween_large_icon.bind(tex))
		statusTween.tween_interval(0.05)
		await statusTween.finished
	
	statusTween = null
	return index


func tween_large_icon(tex : Texture) -> void:
	StatusIconLarge.texture = tex


func initiate_healing_effect() -> void:
	CurrentStatus = StatusEffect.HEALING
	var healAmount : int = PointValue / 10
	var moves : int = healAmount / 5
	start_move_counter(moves)
	set_large_status_icon()
	StatusLabel.text = "+" + str(PointValue / 10)
	Dispatch.PlayerHealthEffect.emit(healAmount)


func initiate_cooldown_effect() -> void:
	CurrentStatus = StatusEffect.COOLDOWN
	start_move_counter(3)
	set_large_status_icon()


func initiate_locked_effect(moves : int) -> void:
	CurrentStatus = StatusEffect.LOCKED
	start_move_counter(moves)
	set_large_status_icon()


func set_large_status_icon() -> void:
	var key = CurrentStatus
	StatusIconLarge.texture = VFX.StatusIcons[key][MoveCounter]
	StatusIconSmall.texture = null
	StatusLabel.text = ""
	StatusLabel.modulate = Color.WHITE


func start_move_counter(moves : int) -> void:
	MoveLimit = moves
	MoveCounter = 0


func increment_move_counter() -> void:
	if MoveLimit == -1:
		return
	
	MoveCounter += 1
	check_status_effect()


func check_status_effect() -> void:
	match CurrentStatus:
		StatusEffect.HEALING:
			if MoveLimit > 0 and MoveCounter >= MoveLimit:
				reset_status_effect()
			else:
				increment_healing_status_effect()
		StatusEffect.COOLDOWN:
			if MoveLimit > 0 and MoveCounter >= MoveLimit:
				end_attack_status_effect()
			else:
				increment_cooldown_status_effect()
		StatusEffect.LOCKED:
			if MoveLimit > 0 and MoveCounter == MoveLimit - 1:
				end_locked_status_effect()
			elif MoveLimit > 0 and MoveCounter >= MoveLimit:
				reset_status_effect()


func increment_healing_status_effect() -> void:
	var key = CurrentStatus
	StatusIconLarge.texture = VFX.StatusIcons[key][MoveCounter]
	var healAmount : int = (PointValue / 10) - (5 * MoveCounter)
	StatusLabel.text = "+" + str(healAmount)
	Dispatch.PlayerHealthEffect.emit(healAmount)


func increment_cooldown_status_effect() -> void:
	var key = CurrentStatus
	StatusIconLarge.texture = VFX.StatusIcons[key][MoveCounter]


func end_attack_status_effect() -> void:
	match AffectedAttack:
		Global.Turn.PLAYER:
			Dispatch.PlayerAttackEffect.emit(0)
		Global.Turn.ENEMY:
			Dispatch.EnemyAttackEffect.emit(0)
	AffectedAttack = Global.Turn.NONE
	reset_status_effect()


func end_locked_status_effect() -> void:
	var key = CurrentStatus
	StatusIconLarge.texture = VFX.StatusIcons[key][1]


func reset_status_tween() -> void:
	if statusTween:
		statusTween.kill()
	
	statusTween = create_tween().set_ease(Tween.EASE_IN_OUT)

#endregion

#endregion

#region Timing Control

func one_frame() -> void:
	await get_tree().process_frame

#endregion

#region Debugging TODO: Delete Later!



#endregion
