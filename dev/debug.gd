extends CanvasLayer


#region Exports

@export var DebugPanel : Control
@export var StagesToClear : SpinBox
@export var Enemy : OptionButton
@export var Victor : OptionButton

#endregion

#region Public Variables

var GameManager : AGM

#endregion

#region Initialization

func _ready() -> void:
	self.visible = false
	set_enemies()


func set_enemies() -> void:
	var keys = CombatManager.ENEMIES.DB.keys()
	for key in keys:
		Enemy.add_item(CombatManager.ENEMIES.DB[key].Name, key)

#endregion

#region Input Event Functions

func _input(event: InputEvent) -> void:
	if not OS.has_feature("editor"):
		return
	
	if event.is_action_pressed("toggle_debug"):
		self.visible = !self.visible

#endregion

#region Gameplay Functions

func on_restart_game_button_pressed() -> void:
	Global.StagesToClear = StagesToClear.value
	get_tree().change_scene_to_file("res://game/game.tscn")


func on_set_enemy_button_pressed() -> void:
	var id = Enemy.selected
	
	var entry = CombatManager.ENEMIES.DB[id]
	var data : EnemyData = EnemyData.new()
	data.ID = id
	data.Name = entry.Name
	data.Attacks = entry.Attacks
	data.MaxDefense = entry.MaxDefense
	data.MaxHealth = entry.MaxHealth
	data.SpecialMove = entry.SpecialMove
	data.PointValue = entry.PointValue
	data.Stage = entry.Stage
	data.Portrait = entry.Portrait
	
	Dispatch.PlaceEnemy.emit(data)


func on_launch_enemy_attack_button_pressed() -> void:
	GameManager.CurrentEnemy.do_attack()


func on_launch_enemy_defense_button_pressed() -> void:
	GameManager.CurrentEnemy.do_defense()


func on_launch_enemy_special_attack_button_pressed() -> void:
	GameManager.CurrentEnemy.do_special_move()


func on_defeat_enemy_button_pressed() -> void:
	GameManager.CurrentEnemy.take_damage(GameManager.CurrentEnemy.CurrentHealth + GameManager.CurrentEnemy.CurrentDefense)


func on_launch_player_attack_button_pressed() -> void:
	for i in 3:
		GameManager.Validator.selectedCards.append(GameManager.Deck.CurrentHand[i])
	GameManager.Validator.send_attack()


func on_launch_player_defense_button_pressed() -> void:
	for i in 3:
		GameManager.Validator.selectedCards.append(GameManager.Deck.CurrentHand[i])
	GameManager.Validator.send_defense()


func on_launch_player_combo_button_pressed() -> void:
	for i in 3:
		GameManager.Validator.selectedCards.append(GameManager.Deck.CurrentHand[i])
	GameManager.Validator.send_both()


func on_restore_player_health_button_pressed() -> void:
	GameManager.Player.restore_to_full_health()
	GameManager.Player.restore_full_defense()


func on_list_cards_in_hand_button_pressed() -> void:
	var deckHand : Array[String] = []
	GameManager.Deck.CurrentHand.sort_custom(Util.sort_by_suit)
	for card:BaseCard in GameManager.Deck.CurrentHand:
		deckHand.append(card.Name)
	
	var hand  = GameManager.Deck.Hand.CardHolder.get_children()
	hand.sort_custom(Util.sort_by_suit)
	
	var handHand : Array[String] = []
	for card:BaseCard in hand:
		handHand.append(card.Name)
	
	send_update(str(deckHand.size()) + " Cards In Deck Hand:")
	print(deckHand)
	send_update(str(handHand.size()) + " Cards In HandController:")
	print(handHand)


func on_find_missing_cards_button_pressed() -> void:
	var cards : Array[BaseCard] = []
	var hand = GameManager.Deck.Hand.CardHolder.get_children()
	var missingCards : Array[BaseCard] = []
	
	for card:BaseCard in GameManager.Deck.CurrentHand:
		cards.append(card)
	
	for card:BaseCard in cards:
		if GameManager.Deck.CurrentHand.has(card) and hand.has(card):
			continue
		else:
			missingCards.append(card)
	
	if missingCards.is_empty():
		send_update("All cards accounted for.")
		return
	
	var cardDetails : Dictionary = {}
	
	for card:BaseCard in missingCards:
		var offscreen : String = "No" if DebugPanel.get_global_rect().has_point(card.global_position) else "Yes"
		
		cardDetails[card.Name] = {
			"State": BaseCard.CardState.keys()[card.CurrentState].capitalize(),
			"Parent": card.get_parent().name,
			"Position": card.global_position,
			"Visible": card.is_visible_in_tree(),
			"Offscreen": offscreen
		}
	
	send_update("Details on Missing Card(s):")
	print(cardDetails)


func on_end_stage_button_pressed() -> void:
	if Victor.selected == 0:
		GameManager.on_player_lost_stage()
	else:
		GameManager.on_player_cleared_stage()


func on_end_game_button_pressed() -> void:
	GameManager.on_player_cleared_all_stages()

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	print_rich("[color=goldenrod]DEBUG: " + update + "[/color]")

#endregion
