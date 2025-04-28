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
## The Bus Index of the Ambience Audio Bus
const AMBIENCE = 3

#endregion

#region Exports

@export_group("Players")
## The AudioStreamPlayer that plays music in the game.
@export var Music : AudioStreamPlayer
## The AudioStreamPlayer that plays sound effects in the game.
@export var Effects : AudioStreamPlayer
@export var Ambience : AudioStreamPlayer

@export_group("Tracks")
## An array of AudioStream objects that can be used to play music in the game.
@export var MusicTracks : Array[AudioStream] = []
## A dictionary of strings and AudioStream objects that can be used to play
## sound effects in the game.
@export var EffectsTracks : Dictionary = {
	"Game": {
		"Attack": [],
		"Cards": [],
		"Defense": [],
		"Impact": []
	},
	"Transition": {
		"NewStage": [],
		"PlayerLost": [],
		"PlayerWon": [],
	},
	"UI": {
		"Click": [],
		"Confirm": [],
		"Error": [],
		"Hover": []
	}
}

@export var AmbienceTracks : Dictionary[String, AudioStream] = {}

#endregion

#region Private Variables

var _currentTrack : int = -1

var musicVol : float
var musicTween : Tween
var ambVol : float
var ambienceTween : Tween

#endregion

#region Initialization

func _ready() -> void:
	adjust_global_volume(SaveData.GlobalVolume)
	adjust_music_volume(SaveData.MusicVolume)
	adjust_effect_volume(SaveData.EffectsVolume)
	adjust_ambience_volume(SaveData.AmbienceVolume)

#endregion

#region Life Cycle Functions

func _process(_delta : float) -> void:
	if !Music.playing and MusicTracks.size() > 0:
		_play_next_song()

#endregion

#region User Input Functions

## Adjusts the volume of the Global Audio Bus.
func adjust_global_volume(newVol : float) -> void:
	AudioServer.set_bus_volume_db(GLOBAL,linear_to_db(newVol))


## Adjust the volume of the Music Audio Bus.
func adjust_music_volume(newVol : float) -> void:
	music_volume(newVol)
	musicVol = newVol


## Adjust the volume of the Effects Audio Bus.
func adjust_effect_volume(newVol : float) -> void:
	AudioServer.set_bus_volume_db(EFFECTS,linear_to_db(newVol))


func adjust_ambience_volume(newVol : float) -> void:
	ambience_volume(newVol)
	ambVol = newVol

#endregion

#region Gameplay Functions

## Finds the AudioStream associated with the given key and plays it through the
## [param Effects] AudioStreamPlayer.
func play_sfx(type: String, effect : String = "", index : int = -1) -> void:
	var track : AudioStream
	match type:
		"Game":
			if index == -1:
				track = EffectsTracks.Game[effect].pick_random()
			else:
				track = EffectsTracks.Game[effect][index]
		"Transition":
			track = EffectsTracks.Transition[effect][0]
		"UI":
			if index == -1:
				track = EffectsTracks.UI[effect].pick_random()
			else:
				track = EffectsTracks.UI[effect][index]
	
	if !track:
		return
	
	Effects.stream = track
	Effects.play()


func play_ambience(stage : String) -> void:
	if !AmbienceTracks.has(stage):
		return
	
	Ambience.stream = AmbienceTracks[stage]
	Ambience.play()


func cross_fade_ambience(nextTrack : String) -> void:
	reset_amb_tween()
	ambienceTween.tween_method(ambience_volume, ambVol, 0.0, 0.5)
	ambienceTween.tween_callback(switch_ambience_tracks.bind(nextTrack))
	ambienceTween.tween_method(ambience_volume, 0.0, ambVol, 0.5)


func ambience_volume(vol : float) -> void:
	AudioServer.set_bus_volume_db(AMBIENCE,linear_to_db(vol))


func switch_ambience_tracks(newTrack : String) -> void:
	Ambience.stream = AmbienceTracks[newTrack]
	Ambience.play()


func reset_amb_tween() -> void:
	if ambienceTween:
		ambienceTween.kill()
	
	ambienceTween = create_tween().set_trans(Tween.TRANS_LINEAR)

#endregion

#region Aesthetics

func _play_next_song() -> void:
	_currentTrack += 1
	if _currentTrack >= MusicTracks.size(): _currentTrack = 0
	Music.stream = MusicTracks[_currentTrack]
	Music.play()


func cross_fade_music(nextTrack : int) -> void:
	reset_music_tween()
	musicTween.tween_method(music_volume, musicVol, 0.0, 0.5)
	musicTween.tween_callback(switch_music_tracks.bind(nextTrack))
	musicTween.tween_method(music_volume, 0.0, musicVol, 0.5)
	await musicTween.finished
	musicTween = null


func music_volume(vol : float) -> void:
	AudioServer.set_bus_volume_db(MUSIC,linear_to_db(vol))


func switch_music_tracks(newTrack : int) -> void:
	Music.stream = MusicTracks[newTrack]
	Music.play()
	_currentTrack = newTrack

func reset_music_tween() -> void:
	if musicTween:
		musicTween.kill()
	
	musicTween = create_tween().set_trans(Tween.TRANS_LINEAR)

#endregion
