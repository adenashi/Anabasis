class_name BaseEnemy extends Node


#region Signals

signal EnemyDied(enemy : BaseEnemy)

#endregion

#region Public Variables

#region Stats

var Name : String
var Data : EnemyData

var Attacks : Array[int]

var MaxHealth : int
var CurrentHealth : int

var MaxDefense : int
var CurrentDefense : int

var SpecialMove : Callable

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

#region Special Moves

func thunderclap() -> void:
	pass


func barrage() -> void:
	pass


func shackle() -> void:
	pass


func betrayal() -> void:
	pass


func transform() -> void:
	pass


func scorch() -> void:
	pass


func eclipse() -> void:
	pass


func whirlwind() -> void:
	pass


func slice() -> void:
	pass


func seism() -> void:
	pass


func dispel() -> void:
	pass


func fury() -> void:
	pass


func burst() -> void:
	pass


func sunder() -> void:
	pass


func salvo() -> void:
	pass


func bane() -> void:
	pass


func blight() -> void:
	pass


func blizzard() -> void:
	pass


func purge() -> void:
	pass


func bolt() -> void:
	pass

#endregion

#region Debugging TODO: Delete Later!

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[5].to_html(false)
	print_rich("[color=#"+color+"]CE: " + update + "[/color]")

#endregion
