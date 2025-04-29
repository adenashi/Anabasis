class_name FieldController extends Node2D


#region Constants

const EFFECTS : Dictionary = {
	"Star": preload("res://assets/effects/star_particle_2.tscn"),
	"Beam": preload("res://assets/effects/beam_particle.tscn"),
	"Circle": preload("res://assets/effects/circle_particle.tscn"),
	"Slash": preload("res://assets/effects/twirl_particle.tscn")
}

#endregion

#region Exports

@export var Path : Path2D
@export var StartingPositions : Dictionary[PathFollow2D, float] = {}
@export var AsiMarker : Marker2D
@export var EnemyMarker : Marker2D

#endregion

#region Public Variables

var Player : PlayerController
var Enemy : BaseEnemy

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
		cards[i].scale = Vector2.ONE
		await cards[i].move_to_position(points[i].global_position, 0.2)
		cards[i].reparent(points[i])
		await get_tree().create_timer(0.1).timeout
	
	for i in range(usedPoints.size() - 1, -1, -1):
		await spawn_attack_effect(usedPoints[i])


func spawn_attack_effect(point : PathFollow2D) -> void:
	var card : BaseCard = point.get_child(0)
	var slash : CPUParticles2D = EFFECTS.Slash.instantiate()
	add_child(slash)
	slash.global_position = point.global_position
	slash.emitting = true
	AM.play_sfx("Game", "Attack",4)
	card.hide()
	await slash.finished
	AM.play_sfx("Game", "Impact",3)
	Enemy.take_damage(card.Value)
	slash.queue_free()


func show_player_defense(cards : Array[BaseCard]) -> void:
	var defense : int = (cards.front().PointValue / 10)
	await spawn_defense_effect(cards.size(), defense)


func spawn_defense_effect(amount : int, defense : int) -> void:
	for i in range(amount):
		var circle : CPUParticles2D = EFFECTS.Circle.instantiate()
		add_child(circle)
		circle.position = AsiMarker.position
		circle.emitting = true
		AM.play_sfx("Game", "Defense")
		await circle.finished
		Player.add_defense(defense)
		circle.queue_free()


func show_player_double_action(cards : Array[BaseCard]) -> void:
	var defense : int = (cards.front().PointValue / 10)
	await spawn_defense_effect(cards.size(), defense)
	await show_player_attack(cards)


func show_enemy_attack() -> void:
	var attack : int = Enemy.current_attack()
	send_update(str(attack) + " Damage to Player")
	Dispatch.UpdateEnemyAttack.emit(attack)
	
	var starStart : CPUParticles2D = EFFECTS.Star.instantiate()
	var starEnd : CPUParticles2D = EFFECTS.Star.instantiate()
	var beam : CPUParticles2D = EFFECTS.Beam.instantiate()
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
	
	Player.take_damage(attack)
	
	starStart.queue_free()
	beam.queue_free()
	starEnd.queue_free()
	
	Dispatch.UpdateEnemyAttack.emit(0)


func show_enemy_defense(amount : int) -> void:
	for i in range(3):
		var circle : CPUParticles2D = EFFECTS.Circle.instantiate()
		add_child(circle)
		circle.position = EnemyMarker.position
		circle.emitting = true
		AM.play_sfx("Game", "Defense")
		await circle.finished
		Enemy.CurrentDefense += amount
		if Enemy.CurrentDefense > Enemy.MaxDefense:
			Enemy.CurrentDefense = Enemy.MaxDefense
		Dispatch.UpdateEnemyDefense.emit(Enemy.MaxDefense, Enemy.CurrentDefense)
		circle.queue_free()


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
