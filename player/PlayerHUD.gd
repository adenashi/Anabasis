class_name PlayerHUD extends Control


#region Constants

const SEGMENT_HEIGHT : float = 9.0
const UPDATE_SPEED : float = 0.2

#endregion

#region Exports

@export_group("Controls")
@export var CardImage : TextureRect
@export var Attack : Label

@export_subgroup("Health Bar")
@export var HealthLabel : Label
@export var HealthSegments : PanelContainer
@export var HealthEmpty : TextureRect
@export var HealthFull : TextureRect

@export_subgroup("Defense Bar")
@export var DefenseLabel : Label
@export var DefenseSegments : PanelContainer
@export var DefenseEmpty : TextureRect
@export var DefenseFull : TextureRect

#endregion

#region Private Variables

var health : int : set = set_health
var fake_health : int : set = set_fake_health
var defense : int : set = set_defense
var fake_defense : int : set = set_fake_defense

var healthSegmentTween : Tween
var defenseSegmentTween : Tween
var healthLabelTween : Tween
var defenseLabelTween : Tween

#endregion

#region Initialization

func _ready() -> void:
	Dispatch.UpdatePlayerHealth.connect(update_health)
	Dispatch.UpdatePlayerDefense.connect(update_defense)
	Dispatch.UpdatePlayerAttack.connect(update_attack)

#endregion

#region Health and Defense

func update_health(segments : int, value : int) -> void:
	HealthEmpty.custom_minimum_size.x = SEGMENT_HEIGHT * roundi(segments / 10)
	if value > health:
		if value == segments:
			HealthFull.show()
			HealthFull.size.x = SEGMENT_HEIGHT * roundi(segments / 10)
		else:
			add_health(value - health)
	elif value < health:
		if value == 0:
			HealthFull.hide()
		else:
			remove_health(segments - value)
	
	health = value


func update_defense(segments : int, value : int) -> void:
	DefenseEmpty.custom_minimum_size.y = SEGMENT_HEIGHT * roundi(segments / 10)
	if value > defense:
		if value == segments:
			DefenseFull.show()
			DefenseFull.size.y = SEGMENT_HEIGHT * roundi(segments / 10)
		else:
			add_defense(value - defense)
	elif value < defense:
		if value == 0:
			DefenseFull.hide()
		else:
			remove_defense(segments - value)
	
	defense = value


func update_attack(amount : int) -> void:
	Attack.text = str(amount)

#endregion

#region Aesthetics

func remove_health(amount : int) -> void:
	var segments : int = roundi(amount / 10)
	var speed : float = (1.0 / segments) / 2
	
	if healthSegmentTween:
		healthSegmentTween.kill()
	for i in range(segments - 1, -1, -1):
		healthSegmentTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		healthSegmentTween.tween_property(HealthFull, "size:x", HealthFull.size.x - SEGMENT_HEIGHT, speed)
		healthSegmentTween.tween_interval(speed)
		await healthSegmentTween.finished
	
	healthSegmentTween = null


func add_health(amount : int) -> void:
	if !HealthFull.is_visible_in_tree():
		HealthFull.show()
	
	var segments : int = roundi(amount / 10)
	var speed : float = (1.0 / segments) / 2
	
	if healthSegmentTween:
		healthSegmentTween.kill()
	for i in range(1, segments + 1):
		healthSegmentTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		healthSegmentTween.tween_property(HealthFull, "size:x", HealthFull.size.x + SEGMENT_HEIGHT, speed)
		healthSegmentTween.tween_interval(speed)
		await healthSegmentTween.finished
	
	healthSegmentTween = null


func remove_defense(amount : int) -> void:
	var segments : int = roundi(amount / 10)
	var speed : float = (1.0 / segments) / 2
	
	if defenseSegmentTween:
		defenseSegmentTween.kill()
	for i in range(segments - 1, -1, -1):
		defenseSegmentTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		defenseSegmentTween.tween_property(DefenseFull, "size:y", DefenseFull.size.y - SEGMENT_HEIGHT, speed)
		defenseSegmentTween.tween_interval(speed)
		await defenseSegmentTween.finished
	
	defenseSegmentTween = null


func add_defense(amount : int) -> void:
	if !DefenseFull.is_visible_in_tree():
		DefenseFull.show()
	
	var segments : int = roundi(amount / 10)
	var speed : float = (1.0 / segments) / 2
	
	if defenseSegmentTween:
		defenseSegmentTween.kill()
	for i in range(1, segments + 1):
		defenseSegmentTween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		defenseSegmentTween.tween_property(DefenseFull, "size:y", DefenseFull.size.y + SEGMENT_HEIGHT, speed)
		defenseSegmentTween.tween_interval(speed)
		await defenseSegmentTween.finished
	
	defenseSegmentTween = null


func set_health(value : int) -> void:
	health = value
	if healthLabelTween:
		healthLabelTween.kill()
	healthLabelTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	healthLabelTween.tween_property(self, "fake_health", health, UPDATE_SPEED)
	await healthLabelTween.finished
	healthLabelTween = null


func set_fake_health(value : int) -> void:
	fake_health = value
	HealthLabel.text = str(fake_health)


func set_defense(value : int) -> void:
	defense = value
	if defenseLabelTween:
		defenseLabelTween.kill()
	defenseLabelTween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	defenseLabelTween.tween_property(self, "fake_defense", defense, UPDATE_SPEED)
	await defenseLabelTween.finished
	defenseLabelTween = null


func set_fake_defense(value : int) -> void:
	fake_defense = value
	DefenseLabel.text = str(fake_defense)

#endregion

#region Debugging TODO: Delete Later!



#endregion
