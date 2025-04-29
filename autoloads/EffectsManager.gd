extends Node


#region Enums



#endregion

#region Constants



#endregion

#region Signals



#endregion

#region Exports
## Icons used by [BaseCard] to show current [enum BaseCard.StatusEffect]:
## [br] 1: Attack[br] 2: Defense[br] 3: Combo[br] 4: Active [br] 5: Rolling [br] 6: Healing[br] 7: Cooldown[br] 8: Locked
@export var StatusIcons : Dictionary = {
	BaseCard.StatusEffect.ATTACK:[],
	BaseCard.StatusEffect.DEFENSE:[],
	BaseCard.StatusEffect.COMBO:[],
	BaseCard.StatusEffect.ACTIVE:[],
	BaseCard.StatusEffect.ROLLING:[],
	BaseCard.StatusEffect.HEALING:[],
	BaseCard.StatusEffect.COOLDOWN:[],
	BaseCard.StatusEffect.LOCKED:[],
}

## Particle prefabs used by the [FieldController] when showing attacks.
@export var Attacks : Dictionary[String, PackedScene] = {
	"Beam": preload("res://assets/effects/beam_particle.tscn"),
	"Slash": preload("res://assets/effects/twirl_particle.tscn")
}

## Particle prefabs used by the [FieldController] when showing impacts.
@export var Impacts : Dictionary[String, PackedScene] ={
	"Star": preload("res://assets/effects/star_particle_2.tscn"),
}

## Particle prefabs used by the [FieldController] when showing added defense.
@export var Defense : Dictionary[String, PackedScene] = {
	"Circle": preload("res://assets/effects/circle_particle.tscn"),
}

#endregion

#region Public Variables



#endregion

#region Private Variables



#endregion

#region Initialization

func _ready() -> void:
	pass

#endregion

#region Life Cycle Functions

func _process(_delta : float) -> void:
	pass

#endregion

#region Input Event Functions



#endregion

#region Gameplay Functions



#endregion

#region Aesthetics



#endregion

#region Debugging TODO: Delete Later!



#endregion
