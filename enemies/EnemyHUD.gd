class_name EnemyHUD extends PlayerHUD

#region Exports

@export_group("Controls")
@export var EnemyName : Label

#endregion

#region Initialization

func _ready() -> void:
	Dispatch.PlaceEnemy.connect(on_new_enemy)
	Dispatch.UpdateEnemyHealth.connect(update_health)
	Dispatch.UpdateEnemyDefense.connect(update_defense)
	Dispatch.UpdateEnemyAttack.connect(update_attack)

#endregion

#region Update Enemy

func on_new_enemy(enemy : EnemyData) -> void:
	var img = load(enemy.Portrait)
	CardImage.texture = img
	EnemyName.text = enemy.Name
	Attack.text = str(0)
	update_health(enemy.MaxHealth, enemy.MaxHealth)
	update_defense(enemy.MaxDefense, enemy.MaxDefense)

#endregion

#region Debugging TODO: Delete Later!



#endregion
