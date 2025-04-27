class_name BaseEnemy extends Node


#region Signals

signal EnemyDied(enemy : BaseEnemy)

#endregion

#region Public Variables

#region Stats

var Name : String
var Data : EnemyData

var BaseAttack : int

var MaxHealth : int
var CurrentHealth : int

var MaxDefense : int
var CurrentDefense : int

#endregion

#region References

var Deck : DeckManager
var Player : PlayerController

#endregion

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

func make_free_move() -> void:
	var chance : int = randi_range(1,20)
	if chance % 2 == 0:
		do_defense()
	else:
		do_attack()


func do_attack() -> void:
	send_update("Attacking for free move.")
	Player.take_damage(BaseAttack)


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
	
	CurrentDefense += defense * 3
	if CurrentDefense > MaxDefense:
		CurrentDefense = MaxDefense
	
	send_update("Adding " + str(defense * 3) + " Defense for free move.")
	Dispatch.UpdateEnemyDefense.emit(MaxDefense, CurrentDefense)


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

func send_update(update : String) -> void:
	var color : String = Util.COLORS.colors[5].to_html(false)
	print_rich("[color=#"+color+"]CE: " + update + "[/color]")

#endregion
