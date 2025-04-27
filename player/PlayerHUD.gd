class_name PlayerHUD extends Control


#region Constants

const SEGMENT_HEIGHT : float = 9.0

#endregion

#region Exports

@export_group("Controls")
@export var CardImage : TextureRect

@export_subgroup("Health Bar")
@export var HealthSegments : PanelContainer
@export var HealthEmpty : TextureRect
@export var HealthFull : TextureRect

@export_subgroup("Defense Bar")
@export var DefenseSegments : PanelContainer
@export var DefenseEmpty : TextureRect
@export var DefenseFull : TextureRect

#endregion

#region Initialization

func _ready() -> void:
	Dispatch.UpdatePlayerHealth.connect(update_health)
	Dispatch.UpdatePlayerDefense.connect(update_defense)

#endregion

#region Health and Defense

func update_health(segments : int, value : int) -> void:
	HealthEmpty.custom_minimum_size.x = SEGMENT_HEIGHT * ceili(segments / 10)
	if value > 0:
		if !HealthFull.is_visible_in_tree():
			HealthFull.show()
		HealthFull.custom_minimum_size.x = SEGMENT_HEIGHT * ceili(segments / 10)
	else:
		HealthFull.hide()


func update_defense(segments : int, value : int) -> void:
	DefenseEmpty.custom_minimum_size.y = SEGMENT_HEIGHT * ceili(segments / 20)
	if value > 0:
		if !DefenseFull.is_visible_in_tree():
			DefenseFull.show()
		
		DefenseFull.custom_minimum_size.y = SEGMENT_HEIGHT * ceili(segments / 20)
	else:
		DefenseFull.hide()

#endregion

#region Debugging TODO: Delete Later!



#endregion
