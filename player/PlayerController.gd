class_name PlayerController extends Node


#region Public Variables

var CurrentDefense : int
var MaxDefense : int

var CurrentHealth : int
var MaxHealth : int

var CurrentPoints : int

#endregion

#region Initialization

func _ready() -> void:
	MaxHealth = Global.StartingHealth
	CurrentHealth = MaxHealth
	MaxDefense = Global.StartingDefense - 10
	CurrentDefense = MaxDefense


func set_stats(startingHealth : int, startingDefense : int) -> void:
	CurrentHealth = startingHealth
	set_max_health(CurrentHealth)
	update_max_defense(startingDefense)

#endregion

#region Health and Defense Methods

func restore_to_full_health() -> void:
	CurrentHealth = MaxHealth
	Dispatch.UpdatePlayerHealth.emit(MaxHealth, CurrentHealth)


func update_max_defense(maxDefense : int) -> void:
	MaxDefense = maxDefense
	CurrentDefense = MaxDefense
	Dispatch.UpdatePlayerDefense.emit(MaxDefense, CurrentDefense)


func add_defense(defense : int) -> void:
	CurrentDefense += defense
	if CurrentDefense > MaxDefense:
		CurrentDefense = MaxDefense
	Dispatch.UpdatePlayerDefense.emit(MaxDefense, CurrentDefense)


func add_health(health : int) -> void:
	CurrentHealth += health
	if CurrentHealth > MaxHealth:
		CurrentHealth = MaxHealth
	Dispatch.UpdatePlayerHealth.emit(MaxHealth, CurrentHealth)


func set_max_health(newMax : int) -> void:
	MaxHealth = newMax
	if CurrentHealth > MaxHealth:
		CurrentHealth = MaxHealth
	Dispatch.UpdatePlayerHealth.emit(MaxHealth, CurrentHealth)


func take_damage(damage : int) -> void:
	if CurrentDefense > 0:
		if damage >= CurrentDefense:
			damage -= CurrentDefense
			damage = max(0, damage)
			CurrentDefense = 0
			Dispatch.UpdatePlayerDefense.emit(MaxDefense, CurrentDefense)
			CurrentHealth -= damage
			CurrentHealth = max(0, CurrentHealth)
			Dispatch.UpdatePlayerHealth.emit(MaxHealth, CurrentHealth)
		else:
			CurrentDefense -= damage
			Dispatch.UpdatePlayerDefense.emit(MaxDefense, CurrentDefense)
	else:
		CurrentHealth -= damage
		CurrentHealth = max(0, CurrentHealth)
		Dispatch.UpdatePlayerHealth.emit(MaxHealth, CurrentHealth)
	
	if CurrentHealth <= 0:
		Dispatch.PlayerDied.emit()

#endregion

#region Debugging TODO: Delete Later!



#endregion
