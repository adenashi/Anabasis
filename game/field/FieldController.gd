class_name FieldController extends Node2D


#region Exports

@export var Path : Path2D
@export var StartingPositions : Dictionary[PathFollow2D, float] = {}
@export var AsiMarker : Marker2D
@export var EnemyMarker : Marker2D

#endregion

#region Public Variables

var Player : PlayerController
var Enemy : BaseEnemy
var PlayerAttackDebuff : int = 0
var EnemyAttackDebuff : int = 0

#endregion

#region Initialization

func _ready() -> void:
	set_starting_positions()
	Dispatch.EnemyAttacks.connect(show_enemy_attack)
	Dispatch.EnemyDefends.connect(show_enemy_defense)
	Dispatch.PlayerAttackEffect.connect(set_player_attack_debuff)
	Dispatch.EnemyAttackEffect.connect(set_enemy_attack_debuff)
	Dispatch.DoEnemySpecialAttack.connect(show_enemy_special_move)


func set_starting_positions() -> void:
	var points = StartingPositions.keys()
	for point:PathFollow2D in points:
		StartingPositions[point] = point.progress_ratio

#endregion

#region Gameplay Functions

func set_player_attack_debuff(amount : int) -> void:
	PlayerAttackDebuff = abs(amount)
	Dispatch.UpdatePlayerAttack.emit(amount)


func set_enemy_attack_debuff(amount : int) -> void:
	EnemyAttackDebuff = abs(amount)
	Dispatch.UpdateEnemyAttack.emit(amount)


func show_player_attack(cards : Array[BaseCard], isCombo : bool = false) -> void:
	var usedPoints : Array[PathFollow2D] = []
	var points = StartingPositions.keys()
	for i in range(cards.size()):
		usedPoints.append(points[i])
		cards[i].scale = Vector2.ONE
		await cards[i].move_to_position(points[i].global_position, 0.2)
		cards[i].reparent(points[i])
		await get_tree().create_timer(0.1).timeout
	
	for i in range(usedPoints.size() - 1, -1, -1):
		await spawn_attack_effect(usedPoints[i], isCombo)


func spawn_attack_effect(point : PathFollow2D, isCombo : bool = false) -> void:
	var card : BaseCard = point.get_child(0)
	var slash : CPUParticles2D = VFX.Attacks.Slash.instantiate()
	add_child(slash)
	slash.global_position = point.global_position
	slash.emitting = true
	AM.play_sfx("Game", "Attack",4)
	card.reset_status_effect()
	await slash.finished
	AM.play_sfx("Game", "Impact",3)
	await get_tree().create_timer(0.2).timeout
	card.hide()
	if isCombo:
		Enemy.take_damage(max(0, (card.PointValue / 10) - PlayerAttackDebuff))
	else:
		Enemy.take_damage(max(0, (card.Value) - PlayerAttackDebuff))
	slash.queue_free()


func show_player_defense(cards : Array[BaseCard]) -> void:
	var defense : int = (cards.front().PointValue / 10)
	await spawn_defense_effect(cards.size(), defense)


func spawn_defense_effect(amount : int, defense : int) -> void:
	for i in range(amount):
		var circle : CPUParticles2D = VFX.Defense.Circle.instantiate()
		add_child(circle)
		circle.position = AsiMarker.position
		circle.emitting = true
		AM.play_sfx("Game", "Defense",0)
		await circle.finished
		Player.add_defense(defense)
		circle.queue_free()


func show_player_double_action(cards : Array[BaseCard]) -> void:
	var defense : int = (cards.front().PointValue / 10)
	await spawn_defense_effect(cards.size(), defense)
	await show_player_attack(cards, true)


func show_enemy_attack() -> void:
	var attack : int = Enemy.current_attack()
	send_update(str(attack - EnemyAttackDebuff) + " Damage to Player")
	Dispatch.UpdateEnemyAttack.emit(attack)
	
	var starStart : CPUParticles2D = VFX.Impacts.Star.instantiate()
	var starEnd : CPUParticles2D = VFX.Impacts.Star.instantiate()
	var beam : CPUParticles2D = VFX.Attacks.Beam.instantiate()
	add_child(starStart)
	add_child(beam)
	starStart.position = EnemyMarker.position
	starStart.emitting = true
	beam.position = EnemyMarker.position
	beam.emitting = true
	AM.play_sfx("Game", "Attack", 3)
	await beam.finished
	add_child(starEnd)
	starEnd.position = AsiMarker.position
	starEnd.emitting = true
	AM.play_sfx("Game", "Impact", 2)
	await starEnd.finished
	
	Player.take_damage(max(0, attack - EnemyAttackDebuff))
	
	starStart.queue_free()
	beam.queue_free()
	starEnd.queue_free()
	
	Dispatch.UpdateEnemyAttack.emit(0 - EnemyAttackDebuff)


func show_enemy_defense(amount : int) -> void:
	for i in range(3):
		var circle : CPUParticles2D = VFX.Defense.Circle.instantiate()
		add_child(circle)
		circle.position = EnemyMarker.position
		circle.emitting = true
		AM.play_sfx("Game", "Defense",1)
		await circle.finished
		Enemy.CurrentDefense += amount
		if Enemy.CurrentDefense > Enemy.MaxDefense:
			Enemy.CurrentDefense = Enemy.MaxDefense
		Dispatch.UpdateEnemyDefense.emit(Enemy.MaxDefense, Enemy.CurrentDefense)
		circle.queue_free()


func show_enemy_special_move(attack : Dictionary) -> void:
	var cards : Array[BaseCard] = attack.Cards
	var effect : BaseCard.StatusEffect = attack.Effect
	var moves : int = attack.Moves
	for card:BaseCard in cards:
		var spawn : Vector2 = card.global_position
		spawn.x += card.CardImage.size.x / 2
		var star : CPUParticles2D = VFX.Impacts.Star.instantiate()
		add_child(star)
		star.global_position = spawn
		star.emitting = true
		AM.play_sfx("Game", "Impact", 0)
		await star.finished
		card.apply_status_effect(effect, moves)
		await get_tree().create_timer(0.2).timeout


func reset_points() -> void:
	var points = StartingPositions.keys()
	for point:PathFollow2D in points:
		point.progress_ratio = StartingPositions[point]

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color :String = Util.COLORS.colors[3].to_html(false)
	print_rich("[color=#"+color+"]FC: " + update + "[/color]")

#endregion
