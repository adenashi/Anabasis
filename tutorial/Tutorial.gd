class_name TutorialController extends Control

#region Constants

const SPACING : float = 24.0

#endregion

#region Exports

@export_group("Tip Panel", "Tip")
@export var TipPanel : VBoxContainer
@export var TipBody : RichTextLabel

@export_group("Control Refs")
@export var Player : PlayerHUD
@export var Enemy : EnemyHUD

#endregion

#region Private Variables

var tipIndex : int = -1
var firstTipDone : bool

#endregion

#region Initialization

func _ready() -> void:
	connect_to_signals()
	Dispatch.ToggleTutorial.connect(toggle_tutorial)

#endregion

#region Signal Connections

func connect_to_signals() -> void:
	if !Dispatch.FirstStageReached.is_connected(on_first_stage_started):
		Dispatch.FirstStageReached.connect(on_first_stage_started)
	if !Dispatch.RunSelected.is_connected(on_first_run_selected):
		Dispatch.RunSelected.connect(on_first_run_selected)
	if !Dispatch.SequenceSelected.is_connected(on_first_sequence_selected):
		Dispatch.SequenceSelected.connect(on_first_sequence_selected)
	if !Dispatch.PlayerAttacked.is_connected(on_player_attacked):
		Dispatch.PlayerAttacked.connect(on_player_attacked)
	if !Dispatch.InvalidCardsSelected.is_connected(on_invalid_cards_selected):
		Dispatch.InvalidCardsSelected.connect(on_invalid_cards_selected)
	if !Dispatch.EnemyAttacked.is_connected(on_first_enemy_attack):
		Dispatch.EnemyAttacked.connect(on_first_enemy_attack)


func disconnect_from_signals() -> void:
	if Dispatch.FirstStageReached.is_connected(on_first_stage_started):
		Dispatch.FirstStageReached.disconnect(on_first_stage_started)
	if Dispatch.RunSelected.is_connected(on_first_run_selected):
		Dispatch.RunSelected.disconnect(on_first_run_selected)
	if Dispatch.SequenceSelected.is_connected(on_first_sequence_selected):
		Dispatch.SequenceSelected.disconnect(on_first_sequence_selected)
	if Dispatch.PlayerAttacked.is_connected(on_player_attacked):
		Dispatch.PlayerAttacked.disconnect(on_player_attacked)
	if Dispatch.InvalidCardsSelected.is_connected(on_invalid_cards_selected):
		Dispatch.InvalidCardsSelected.disconnect(on_invalid_cards_selected)
	if Dispatch.EnemyAttacked.is_connected(on_first_enemy_attack):
		Dispatch.EnemyAttacked.disconnect(on_first_enemy_attack)

#endregion

#region Input Event Functions

func on_ok_button_pressed() -> void:
	TipPanel.hide()
	hide()
	if tipIndex == 0 and firstTipDone:
		Dispatch.ReadyToStartFirstStage.emit()

#endregion

#region Gameplay Functions

func toggle_tutorial(on : bool) -> void:
	if on:
		connect_to_signals()
	else:
		disconnect_from_signals()

#endregion

#region Showing Tips

func on_first_stage_started() -> void:
	TipBody.text = "[p align=center][b]WELCOME TO THE ABYSS.[/b][/p][p align=center][b]USE YOUR CARDS TO CLIMB YOUR WAY OUT.[/b][/p]"
	TipBody.text += "[p] [/p]"
	TipBody.text += "[ul][p] Runs (3 of more cards of the same rank) will add to your [img=16]res://assets/ui/shield.png[/img] Armor.[/p]"
	TipBody.text += "[p] Sequences (3 or more cards of the same suit in sequential order) become your  [img=16]res://assets/ui/sword.png[/img] Attack against the enemy.[/p]"
	TipBody.text += "[p] Use your attacks to break through the enemy's [img=16]res://assets/ui/shield.png[/img] Armor and deplete their [img=16]res://assets/ui/skull.png[/img] Health in order to clear the stage.[/p][/ul]"
	TipBody.text += "[p] [/p]"
	TipBody.text += "[p align=center]But act wisely -- whenever you attack or defend, the enemy will retaliate.[/p]"
	TipPanel.set_anchors_preset(Control.PRESET_CENTER)
	tipIndex += 1
	firstTipDone = true
	show()
	TipPanel.show()
	Dispatch.FirstStageReached.disconnect(on_first_stage_started)


func on_first_run_selected() -> void:
	TipBody.text = "[p align=center]Press the PLAY Button to add your run to your [img=16]res://assets/ui/shield.png[/img] Armor.[/p]"
	TipPanel.set_anchors_preset(Control.PRESET_CENTER)
	tipIndex += 1
	show()
	TipPanel.show()
	Dispatch.RunSelected.disconnect(on_first_run_selected)


func on_first_sequence_selected() -> void:
	TipBody.text = "[p align=center]Press the PLAY Button to launch your first [img=16]res://assets/ui/sword.png[/img] Attack.[/p]"
	TipPanel.set_anchors_preset(Control.PRESET_CENTER)
	tipIndex += 1
	show()
	TipPanel.show()
	Dispatch.SequenceSelected.disconnect(on_first_sequence_selected)


func on_invalid_cards_selected() -> void:
	TipBody.text = "[p align=center]You can discard cards from your hand by clicking them and pressing the DISCARD button.[/p]"
	TipBody.text += "[p] [/p]"
	TipBody.text += "[p align=center]When your deck runs out of cards, all of the cards in your Discard pile will be reshuffled.[/p]"
	TipPanel.set_anchors_preset(Control.PRESET_CENTER)
	tipIndex += 1
	show()
	TipPanel.show()
	Dispatch.InvalidCardsSelected.disconnect(on_invalid_cards_selected)


func on_player_attacked() -> void:
	TipBody.text = "[p align=center]Each [img=16]res://assets/ui/sword.png[/img] Attack you launch increases your score.[/p]"
	TipBody.text += "[p] [/p]"
	TipBody.text += "[p align=center]But be mindful of your [img=16]res://assets/ui/shield.png[/img] Armor - when it's at zero, the enemy will begin to deplete your [img=16]res://assets/ui/skull.png[/img] Health.[/p]"
	TipPanel.set_anchors_preset(Control.PRESET_CENTER)
	tipIndex += 1
	show()
	TipPanel.show()
	Dispatch.PlayerAttacked.disconnect(on_player_attacked)


func on_first_enemy_attack() -> void:
	TipBody.text = "[p align=center][b]GOOD LUCK.[/b][/p][p] [/p][p]Hope you get out of here soon.[/p]"
	TipPanel.set_anchors_preset(Control.PRESET_CENTER)
	tipIndex += 1
	show()
	TipPanel.show()
	Dispatch.EnemyAttacked.disconnect(on_first_enemy_attack)


#endregion

#region Positioning

func on_label_size_changed() -> void:
	pass

func at_screen_center() -> Vector2:
	var pos : Vector2 = Vector2.ZERO
	
	var screenCenter : Vector2
	screenCenter.x = get_viewport_rect().size.x / 2
	screenCenter.y = get_viewport_rect().size.y / 2
	pos.x = screenCenter.x - TipPanel.size.x / 2
	pos.y = screenCenter.y - TipPanel.size.y / 2
	
	return pos

#endregion

#region Debugging TODO: Delete Later!



#endregion
