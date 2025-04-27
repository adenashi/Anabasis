class_name BaseEnemy extends Node


#region Signals

signal EnemyDied(enemy : BaseEnemy)

#endregion

#region Public Variables

var Name : String
var Data : EnemyData

var BaseAttack : int

var MaxHealth : int
var CurrentHealth : int

var MaxDefense : int
var CurrentDefense : int

#endregion

#region Initialization

func init_enemy(data : EnemyData) -> void:
	Data = data
	Name = Data.Name
	BaseAttack = Data.Attack
	MaxDefense = Data.MaxDefense
	MaxHealth = Data.MaxHealth
	CurrentDefense = MaxDefense
	CurrentHealth = MaxHealth
	name = Name

#endregion

#region Gameplay Functions

func take_damage(damage : int) -> void:
	if CurrentDefense > 0:
		if damage >= CurrentDefense:
			damage -= CurrentDefense
			damage = max(0, damage)
			CurrentDefense = 0
			Dispatch.UpdateEnemyDefense.emit(MaxDefense, CurrentDefense)
			if damage > 0:
				CurrentHealth -= damage
				Dispatch.UpdateEnemyHealth.emit(MaxHealth, CurrentHealth)
		else:
			CurrentDefense -= damage
			Dispatch.UpdateEnemyDefense.emit(MaxDefense, CurrentDefense)
	else:
		CurrentHealth -= damage
		Dispatch.UpdateEnemyHealth.emit(MaxHealth, CurrentHealth)
	
	if CurrentHealth <= 0:
		EnemyDied.emit(self)


func reset_stats() -> void:
	MaxDefense = Data.MaxDefense
	MaxHealth = Data.MaxHealth
	CurrentDefense = MaxDefense
	CurrentHealth = MaxHealth


func reset_hud() -> void:
	Dispatch.UpdateEnemyHealth.emit(MaxHealth, CurrentHealth)
	Dispatch.UpdateEnemyDefense.emit(MaxDefense, CurrentDefense)

#endregion

#region Aesthetics

#region Debugging TODO: Delete Later!



#endregion
