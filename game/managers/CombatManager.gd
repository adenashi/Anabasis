class_name CombatManager extends Node


#region Constants

const ENEMIES = preload("uid://bt8m2els0rd13")

#endregion

#region Exports

@export var Field : FieldController

#endregion

#region Public Variables

var Deck : DeckManager
var Player : PlayerController
var CurrentEnemy : BaseEnemy

#endregion

#region Private Variables

var currentTurn : Global.Turn

var currentEnemyAttack : int
var currentEnemyDebuff : int

var AvailableEnemies : Array[int] = []

#endregion

#region Initialization

func _ready() -> void:
	#Dispatch.EndPlayerTurn.connect(start_enemy_turn)
	Dispatch.StartEnemyTurn.connect(start_enemy_turn)
	Dispatch.SpawnNewEnemy.connect(spawn_new_enemy)
	Dispatch.AddDefense.connect(add_to_defense)
	Dispatch.PerformAttack.connect(perform_attack)
	Dispatch.DoAttackAndDefense.connect(add_defense_and_perform_attack)
	add_available_enemies()


func add_available_enemies() -> void:
	var keys = ENEMIES.DB.keys()
	for key in keys:
		AvailableEnemies.append(key)
	
	AvailableEnemies.shuffle()

#endregion

#region Spawn Enemy

func spawn_new_enemy() -> void:
	if AvailableEnemies.is_empty():
		send_update("No more enemies available!")
		return
	
	var id : int = AvailableEnemies.pick_random()
	AvailableEnemies.erase(id)
	
	var entry = ENEMIES.DB[id]
	var data : EnemyData = EnemyData.new()
	data.ID = id
	data.Name = entry.Name
	data.Attacks = entry.Attacks
	data.MaxDefense = entry.MaxDefense
	data.MaxHealth = entry.MaxHealth
	data.SpecialMove = entry.SpecialMove
	data.SpecialMoveDesc = entry.SpecialMoveDesc
	data.PointValue = entry.PointValue
	data.Stage = entry.Stage
	data.Portrait = entry.Portrait
	
	Dispatch.PlaceEnemy.emit(data)

#endregion

#region Turn Management

func start_combat() -> void:
	change_turn(Global.Turn.PLAYER)


func start_enemy_turn() -> void:
	change_turn(Global.Turn.ENEMY)


func change_turn(nextTurn : Global.Turn) -> void:
	currentTurn = nextTurn
	Global.CurrentTurn = nextTurn
	
	if currentTurn == Global.Turn.ENEMY:
		perform_enemy_turn()
	else:
		currentEnemyDebuff = 0

#endregion

#region On Player Turn

#region Attack Methods

func perform_attack(cards : Array[BaseCard]) -> void:
	if currentTurn != Global.Turn.PLAYER:
		return
	
	var points : int = 0
	
	for card:BaseCard in cards:
		var values : Array[int] = get_values(card)
		send_update(CurrentEnemy.Name + " takes " + str(values[0] - Field.PlayerAttackDebuff) + " damage.")
		points += values[1]
	
	if cards.size() > 3:
		var bonus = cards.size() - 3
		bonus *= Global.ExtraCardBonus
		points += bonus
	
	
	await Field.show_player_attack(cards)
	Dispatch.AddPoints.emit(points)
	await Deck.discard_selected_cards(cards)
	await one_frame()
	send_update("Player turn completed.")
	Dispatch.UpdatePlayerAttack.emit(0 - Field.PlayerAttackDebuff)
	Dispatch.EndPlayerTurn.emit()
	
	if currentTurn != Global.Turn.NONE:
		start_enemy_turn()

#endregion

#region Defense Methods

func add_to_defense(cards : Array[BaseCard]) -> void:
	if currentTurn != Global.Turn.PLAYER:
		return
	
	var defense : int = (cards.front().PointValue / 10) * cards.size()
	send_update(str(defense) + " add to Player Defense.")
	
	var points : int = 0
	
	for card:BaseCard in cards:
		var values : Array[int] = get_values(card)
		points += values[1]
	
	
	await Field.show_player_defense(cards)
	Dispatch.AddPoints.emit(points)
	await Deck.discard_selected_cards(cards)
	await one_frame()
	send_update("Player turn completed.")
	Dispatch.EndPlayerTurn.emit()
	
	if currentTurn != Global.Turn.NONE:
		start_enemy_turn()

#endregion

#region Attack and Defense

func add_defense_and_perform_attack(cards : Array[BaseCard]) -> void:
	if currentTurn != Global.Turn.PLAYER:
		return
	
	var defense : int = (cards.front().PointValue / 10) * cards.size()
	send_update(str(defense) + " add to Player Defense.")
	
	var points : int = 0
	
	for card:BaseCard in cards:
		var values : Array[int] = get_values(card)
		points += values[1]
		send_update(CurrentEnemy.Name + " takes " + str(values[0]) + " damage.")
	
	if cards.size() > 3:
		var bonus = cards.size() - 3
		bonus *= Global.ExtraCardBonus
		points += bonus
	
	
	await Field.show_player_double_action(cards)
	Dispatch.AddPoints.emit(points)
	await Deck.discard_selected_cards(cards)
	await one_frame()
	send_update("Player turn completed.")
	Dispatch.UpdatePlayerAttack.emit(0 - Field.PlayerAttackDebuff)
	Dispatch.EndPlayerTurn.emit()
	
	if currentTurn != Global.Turn.NONE:
		start_enemy_turn()

#endregion

#region Getting Values

func get_values(card : BaseCard) -> Array[int]:
	var values : Array[int] = [0,0]
	
	values[0] = card.Value
	values[1] = card.PointValue
	
	return values

#endregion

#endregion

#region On Enemy Turn

func perform_enemy_turn() -> void:
	if Player.CurrentHealth < 0:
		send_update("Player has died!")
		change_turn(Global.Turn.NONE)
		return
	
	if currentTurn != Global.Turn.ENEMY:
		return
	
	await get_tree().create_timer(1.2).timeout
	send_update("Enemy Turn begins.")
	if SaveData.TutorialOn:
		Dispatch.EnemyAttacked.emit()
	
	var action : BaseEnemy.Action = CurrentEnemy.perform_action(false)
	match action:
		BaseEnemy.Action.ATTACK:
			await Field.show_enemy_attack()
		BaseEnemy.Action.DEFEND:
			var poss : Array[int] = [5,10,15]
			await Field.show_enemy_defense(poss.pick_random())
		BaseEnemy.Action.SPECIAL:
			CurrentEnemy.do_special_move()
			await get_tree().create_timer(2.0).timeout
	
	await one_frame()
	if Player.CurrentHealth < 0:
		send_update("Player has died!")
		change_turn(Global.Turn.NONE)
	else:
		send_update("Enemy turn completed.")
		change_turn(Global.Turn.PLAYER)

#endregion

#region Enemy Death

func on_enemy_died(enemy : BaseEnemy) -> void:
	Deck.CanDeal = false
	send_update(enemy.Name + " has been defeated!")
	change_turn(Global.Turn.NONE)
	await get_tree().create_timer(1.5).timeout
	Dispatch.EnemyDied.emit()

#endregion

#endregion

#region Timing Control

func one_frame() -> void:
	await get_tree().process_frame

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color :String = Util.COLORS.colors[2].to_html(false)
	print_rich("[color=#"+color+"]CM: " + update + "[/color]")

#endregion
