class_name BaseEnemy extends Node


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


func perform_action() -> void:
	var chance : int = randi_range(0,100)
	if chance >= 90:
		do_special_move()
	elif chance >= 60:
		do_attack()
	else:
		do_defense()


func do_attack() -> void:
	send_update("Attacking for free move.")
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
	
	send_update("Defending for free move.")
	Dispatch.EnemyDefends.emit(defense)


func do_special_move() -> void:
	send_update("Doing Special Move - " + Data.SpecialMove + " - for free move.")
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
	send_update(Name + " performing " + Data.SpecialMove + ".")


func barrage() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func shackle() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func betrayal() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func transform() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func scorch() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func eclipse() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func whirlwind() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func slice() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func seism() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func dispel() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func fury() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func burst() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func sunder() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func salvo() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func bane() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func blight() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func blizzard() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func purge() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")


func bolt() -> void:
	send_update(Name + " performing " + Data.SpecialMove + ".")

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[2].to_html(false)
	print_rich("[color=#"+color+"]CE: " + update + "[/color]")

#endregion
