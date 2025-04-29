class_name BaseEnemy extends Node


#region Enums

enum Action {
	DEFEND,
	ATTACK,
	SPECIAL
}

#endregion

#region Signals

signal EnemyDied(enemy : BaseEnemy)

#endregion

#region Public Variables

#region Stats

var Name : String
var Data : EnemyData

var Attacks : Array

var MaxHealth : int
var CurrentHealth : int

var MaxDefense : int
var CurrentDefense : int

var SpecialMove : Callable

var IsDead : bool

#endregion

#region References

var Deck : DeckManager

#endregion

#endregion

#region Initialization

func init_enemy(data : EnemyData) -> void:
	Data = data
	Name = Data.Name
	Attacks = Data.Attacks
	MaxDefense = Data.MaxDefense
	MaxHealth = Data.MaxHealth
	CurrentDefense = MaxDefense
	CurrentHealth = MaxHealth
	name = Name
	set_special_move()


func set_special_move() -> void:
	match Data.SpecialMove:
		"Thunderclap":
			SpecialMove = thunderclap
		"Barrage":
			SpecialMove = barrage
		"Shackle":
			SpecialMove = shackle
		"Betrayal":
			SpecialMove = betrayal
		"Transform":
			SpecialMove = transform
		"Scorch":
			SpecialMove = scorch
		"Eclipse":
			SpecialMove = eclipse
		"Whirlwind":
			SpecialMove = whirlwind
		"Slice":
			SpecialMove = slice
		"Seism":
			SpecialMove = seism
		"Dispel":
			SpecialMove = dispel
		"Fury":
			SpecialMove = fury
		"Burst":
			SpecialMove = burst
		"Sunder":
			SpecialMove = sunder
		"Salvo":
			SpecialMove = salvo
		"Bane":
			SpecialMove = bane
		"Blight":
			SpecialMove = blight
		"Blizzard":
			SpecialMove = blizzard
		"Purge":
			SpecialMove = purge
		"Bolt":
			SpecialMove = bolt

#endregion

#region Gameplay Functions

func current_attack() -> int:
	return Attacks.pick_random()


func perform_action(doMove : bool = true) -> Action:
	var chance : int = randi_range(0,100)
	var message : String
	var action : Action
	if chance >= 90:
		message = "Performing Special Attack"
		action = Action.SPECIAL
		if doMove:
			do_special_move()
	elif chance >= 60:
		message = "Attacking"
		action = Action.ATTACK
		if doMove:
			do_attack()
	else:
		message = "Defending"
		action = Action.DEFEND
		if doMove:
			do_defense()
	if doMove:
		message += " on Free Move."
	else:
		message += "."
	send_update(message)
	return action


func do_attack() -> void:
	Dispatch.EnemyAttacks.emit()


func do_defense() -> void:
	var limit : int = Deck.HandLimit
	if Deck.Discard.size() < 9:
		limit = Deck.Discard.size()
	
	var run : Array[BaseCard] = []
	var defense : int = -1
	
	for i in range(0, limit):
		var first : BaseCard = Deck.Discard[i]
		var second : bool
		var third : bool
		for j in range(i, limit):
			if Deck.Discard[j].Value == first.Value:
				if !second:
					second = true
					continue
				elif !third:
					third = true
					break
		if second and third:
			defense = first.PointValue / 10
			break
	
	if defense == -1:
		var possibles : Array[int] = [5,10,15]
		defense = possibles.pick_random()
	
	Dispatch.EnemyDefends.emit(defense)


func do_special_move() -> void:
	SpecialMove.call()


func take_damage(damage : int) -> void:
	if CurrentDefense > 0:
		if damage >= CurrentDefense:
			damage -= CurrentDefense
			damage = max(0, damage)
			CurrentDefense = 0
			Dispatch.UpdateEnemyDefense.emit(MaxDefense, CurrentDefense)
			if damage > 0:
				CurrentHealth -= damage
				CurrentHealth = max(0, CurrentHealth)
				Dispatch.UpdateEnemyHealth.emit(MaxHealth, CurrentHealth)
		else:
			CurrentDefense -= damage
			Dispatch.UpdateEnemyDefense.emit(MaxDefense, CurrentDefense)
	else:
		CurrentHealth -= damage
		CurrentHealth = max(0, CurrentHealth)
		Dispatch.UpdateEnemyHealth.emit(MaxHealth, CurrentHealth)
	
	if IsDead:
		return
	
	if CurrentHealth <= 0:
		EnemyDied.emit(self)
		IsDead = true


func reset_stats() -> void:
	MaxDefense = Data.MaxDefense
	MaxHealth = Data.MaxHealth
	CurrentDefense = MaxDefense
	CurrentHealth = MaxHealth
	IsDead = false


func reset_hud() -> void:
	Dispatch.UpdateEnemyHealth.emit(MaxHealth, CurrentHealth)
	Dispatch.UpdateEnemyDefense.emit(MaxDefense, CurrentDefense)

#endregion

#region Special Moves

func thunderclap() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func barrage() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func shackle() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func betrayal() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func transform() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func scorch() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func eclipse() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func whirlwind() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func slice() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func seism() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func dispel() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func fury() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func burst() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func sunder() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func salvo() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func bane() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func blight() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func blizzard() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func purge() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)


func bolt() -> void:
	var cards : Array[BaseCard]
	
	# Select affected cards here
	
	var attack : Dictionary = {
		"Cards": cards,
		"Effect": BaseCard.StatusEffect.ROLLING,
		"moves": 0
	}
	
	send_update(Name + " performing " + Data.SpecialMove + ".")
	Dispatch.DoEnemySpecialAttack.emit(attack)

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[2].to_html(false)
	print_rich("[color=#"+color+"]CE: " + update + "[/color]")

#endregion
