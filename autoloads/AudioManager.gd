extends Node
## AudioManager
## Set as an Autoload. Adjust the volume levels for the Global, Music, and
## Effects audio busses, and controls music and effects audio throughout the game.
## 
## Player Preferences for Volume levels are held in the [class PlayerPrefs],
## which is loaded and saved by the Global Autoload.
## [br][br]
## [b]Be sure to add the Music and Effects busses in the AudioBusLayout.[/b]


#region Constants

## The Bus Index of the Global Audio Bus.
const GLOBAL = 0
## The Bus Index of the Music Audio Bus.
const MUSIC = 1
## The Bus Index of the Effects Audio Bus.
const EFFECTS = 2

#endregion

#region Exports

@export_group("Players")
## The AudioStreamPlayer that plays music in the game. [br][br] Be sure to change the Bus to "Music".
@export var Music : AudioStreamPlayer
## The AudioStreamPlayer that plays sound effects in the game. [br][br] Be sure to change the Bus to "Effects".
@export var Effects : AudioStreamPlayer

@export_group("Tracks")
## An array of AudioStream objects that can be used to play music in the game.
@export var MusicTracks : Array[AudioStream] = []
## A dictionary of strings and AudioStream objects that can be used to play
## sound effects in the game.
@export var EffectsTracks : Dictionary[String, AudioStream] = {}

#endregion

#region Private Variables

var _currentTrack : int

#endregion

#region Life Cycle Functions

func _process(_delta : float) -> void:
	if !Music.playing and MusicTracks.size() > 0:
		_play_next_song()

#endregion

#region User Input Functions

## Adjusts the volume of the Global Audio Bus.
func adjust_global_volume(newVol : float) -> void:
	AudioServer.set_bus_volume_db(GLOBAL,(newVol))


## Adjust the volume of the Music Audio Bus.
func adjust_music_volume(newVol : float) -> void:
	AudioServer.set_bus_volume_db(MUSIC,(newVol))


## Adjust the volume of the Effects Audio Bus.
func adjust_effect_volume(newVol : float) -> void:
	AudioServer.set_bus_volume_db(EFFECTS,(newVol))

#endregion

#region Gameplay Functions

## Finds the AudioStream associated with the given key and plays it through the
## [param Effects] AudioStreamPlayer.
func play_sfx(effect : String) -> void:
	if !EffectsTracks.has(effect):
		return
	
	Effects.stream = EffectsTracks[effect]
	Effects.play()

#endregion

#region Aesthetics

func _play_next_song() -> void:
	_currentTrack += 1
	if _currentTrack >= MusicTracks.size(): _currentTrack = 0
	Music.stream = MusicTracks[_currentTrack]
	Music.play()

#endregion
