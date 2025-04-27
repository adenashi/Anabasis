class_name FieldController extends Node2D


#region Enums



#endregion

#region Constants



#endregion

#region Signals



#endregion

#region Exports

@export var Path : Path2D
@export var StartingPositions : Dictionary[PathFollow2D, float] = {}

#endregion

#region Public Variables

var Player : PlayerController
var Enemy : BaseEnemy

#endregion

#region Private Variables

var cardTween : Tween
var labelTween : Tween

#endregion

#region Initialization

func _ready() -> void:
	set_starting_positions()
	Dispatch.EnemyAttacks.connect(show_enemy_attack)
	Dispatch.EnemyDefends.connect(show_enemy_defense)


func set_starting_positions() -> void:
	var points = StartingPositions.keys()
	for point:PathFollow2D in points:
		StartingPositions[point] = point.progress_ratio

#endregion

#region Gameplay Functions

func show_player_attack(cards : Array[BaseCard]) -> void:
	var usedPoints : Array[PathFollow2D] = []
	var points = StartingPositions.keys()
	for i in range(cards.size()):
		usedPoints.append(points[i])
		await cards[i].move_to_position(points[i].global_position, 0.5)
		cards[i].reparent(points[i])
	
	reset_card_tween()
	for point:PathFollow2D in usedPoints:
		cardTween.tween_property(point, "progress_ratio", 1.0, 0.7)
		cardTween.tween_callback(spawn_attack_effect.bind(point))
		cardTween.tween_interval(0.2)
	
	await cardTween.finished
	cardTween = null
	
	reset_points()


func spawn_attack_effect(point : PathFollow2D) -> void:
	var card : BaseCard = point.get_child(0)
	card.hide()
	Enemy.take_damage(card.Value)


func show_player_defense(cards : Array[BaseCard]) -> void:
	var defense : int = (cards.front().PointValue / 10) * cards.size()
	
	
	Player.add_defense(defense)


func spawn_defense_attack(point : PathFollow2D) -> void:
	pass


func show_player_double_action(cards : Array[BaseCard]) -> void:
	pass


func show_enemy_attack() -> void:
	
	Player.take_damage(Enemy.BaseAttack)


func show_enemy_defense(amount : int) -> void:
	
	Enemy.CurrentDefense += amount * 3
	if Enemy.CurrentDefense > Enemy.MaxDefense:
		Enemy.CurrentDefense = Enemy.MaxDefense
	
	Dispatch.UpdateEnemyDefense.emit(Enemy.MaxDefense, Enemy.CurrentDefense)


func reset_points() -> void:
	var points = StartingPositions.keys()
	for point:PathFollow2D in points:
		point.progress_ratio = StartingPositions[point]

#endregion

#region Aesthetics

func reset_card_tween() -> void:
	if cardTween:
		cardTween.kill()
	
	cardTween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)


func reset_label_tween() -> void:
	if labelTween:
		labelTween.kill()
	
	labelTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)

#endregion

#region Debugging TODO: Delete Later!



#endregion
