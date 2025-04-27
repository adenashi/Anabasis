class_name Util extends Node
## A class of static utility functions.


#region Constants

const COLORS : ColorPalette = preload("uid://rxo8uyk1wahu")

#endregion

#region Static Functions

## Returns the time it takes for the callable to execute in milliseconds.
static func get_function_runtime(callable : Callable):
	var start_time = Time.get_ticks_msec()
	callable.call()
	var end_time = Time.get_ticks_msec()
	return end_time - start_time


## Creates a repeating timer that calls the supplied function after a set amount of time and parents it to the specified node.
static func run_periodically(parent : Node, function : Callable, period : float):
	var timer = Timer.new()
	timer.set_wait_time(period)
	timer.set_one_shot(false)
	timer.connect("timeout", function)
	parent.add_child(timer)
	timer.start()


## Chooses and returns a rarity from the provided dictionary based on the weights therein.
func get_random_rarity(rarities : Dictionary[String, int]) -> String:
	var total_weight : int = 0
	for weight in rarities.values():
		total_weight += weight
	
	var random_value : int = randi() % total_weight
	var current_weight : int = 0
	
	for rarity in rarities.keys():
		current_weight += rarities[rarity]
		if random_value < current_weight:
			return rarity
	
	return rarities.keys()[0]


static func formatted_game_time(time_in_seconds : int) -> String:
	var seconds = int(round(time_in_seconds % 60))
	@warning_ignore("integer_division")
	var minutes = int(round((time_in_seconds / 60) % 60))
	@warning_ignore("integer_division")
	var hours = int(round((time_in_seconds / 60) / 60))
	
	#returns a string with the format "HH:MM:SS"
	var timeString = "%02d:%02d:%02d" % [hours, minutes, seconds]
	return timeString


## Custom sorter for [BaseCard] based on rank/value.
static func sort_by_rank(a, b) -> bool:
	if int(a.Value) < int(b.Value):
		return true
	return false


## Custom sorter for [BaseCard] based on Suit.
static func sort_by_suit(a, b) -> bool:
	if int(a.Suit) < int(b.Suit):
		return true
	elif int(a.Suit) == int(a.Suit):
			return sort_by_rank(a, b)
	return false

#endregion
