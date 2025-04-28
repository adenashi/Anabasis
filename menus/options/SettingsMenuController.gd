class_name SettingsMenuController extends Control


#region Constants

const RES_OPTIONS = [
	Vector2i(3840,2160),
	Vector2i(2560,1440),
	Vector2i(1920,1080),
	Vector2i(1366,768),
	Vector2i(1280,720),
	Vector2i(1440,900),
	Vector2i(1600,900),
	Vector2i(1024,600),
	Vector2i(800,600)
	]

#endregion

#region Exports

@export_group("Tabs")
@export var Tabs : TabContainer
@export var TabButtons : VBoxContainer

@export_group("UI")
@export var GlobalVolSlider : HSlider
@export var MusicVolSlider : HSlider
@export var EffectsVolSlider : HSlider
@export var AmbienceVolSlider : HSlider
@export var ResolutionDropdown : OptionButton
@export var FullscreenToggle : CheckButton
@export var VSyncToggle : CheckButton
@export var TutorialToggle : CheckButton

#endregion

#region Private Variables

var globalVol : float
var musicVol : float
var effectsVol : float
var ambienceVol : float
var resolution : Vector2i
var fullScreen : bool
var vSync : bool
var tutorialOn : bool

#endregion

#region Initialization

func _ready() -> void:
	connect_tab_buttons()
	call_deferred("set_prefs")


func connect_tab_buttons() -> void:
	for i in range(TabButtons.get_child_count()):
		TabButtons.get_child(i).toggled.connect(show_tab.bind(i))


func set_prefs() -> void:
	globalVol = SaveData.GlobalVolume
	musicVol = SaveData.MusicVolume
	effectsVol = SaveData.EffectsVolume
	resolution = SaveData.Resolution
	fullScreen = SaveData.FullScreen
	vSync = SaveData.VSyncOn
	tutorialOn = SaveData.TutorialOn
	set_ui()


func set_ui() -> void:
	GlobalVolSlider.max_value = 1.0
	GlobalVolSlider.value = globalVol
	
	MusicVolSlider.max_value = 1.0
	MusicVolSlider.value = musicVol
	
	EffectsVolSlider.max_value = 1.0
	EffectsVolSlider.value = effectsVol
	
	for i in range(RES_OPTIONS.size()):
		var label : String = "{x} x {y}".format({"x":RES_OPTIONS[i].x, "y":RES_OPTIONS[i].y})
		ResolutionDropdown.add_item(label, i)
	var resIndex : int = RES_OPTIONS.find(resolution)
	ResolutionDropdown.selected = resIndex
	
	FullscreenToggle.button_pressed = fullScreen
	VSyncToggle.button_pressed = vSync
	TutorialToggle.button_pressed = tutorialOn


#endregion

#region Input Event Functions

func show_tab(_is_on : bool, tab : int) -> void:
	Tabs.current_tab = tab

func on_global_vol_changed(newValue : float) -> void:
	globalVol = newValue
	AM.adjust_global_volume(globalVol)
	SaveData.GlobalVolume = globalVol


func on_music_vol_changed(newValue : float) -> void:
	musicVol = newValue
	AM.adjust_music_volume(musicVol)
	SaveData.MusicVolume = musicVol


func on_effects_vol_changed(newValue : float) -> void:
	effectsVol = newValue
	AM.adjust_effect_volume(effectsVol)
	SaveData.EffectsVolume = effectsVol


func on_ambience_vol_changed(newValue : float) -> void:
	ambienceVol = newValue
	AM.adjust_ambience_volume(ambienceVol)
	SaveData.AmbienceVolume = ambienceVol


func on_resolution_changed(newChoice : int) -> void:
	resolution = RES_OPTIONS[newChoice]
	SaveData.Resolution = resolution
	get_window().set_size(resolution)
	center_window()


func center_window() -> void:
	var screen_center = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(screen_center - window_size / 2)


func on_full_screen_toggled(isOn : bool) -> void:
	fullScreen = isOn
	SaveData.FullScreen = fullScreen
	
	if fullScreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func on_vsync_toggled(isOn : bool) -> void:
	vSync = isOn
	SaveData.VSyncOn = vSync
	if vSync:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


func on_tutorial_toggled(isOn : bool) -> void:
	tutorialOn = isOn
	SaveData.TutorialOn = tutorialOn
	Dispatch.ToggleTutorial.emit(tutorialOn)


func on_back_clicked() -> void:
	SaveData.save_data()
	GUI.hide_settings()


func on_reset_clicked() -> void:
	GlobalVolSlider.value = 0.9
	MusicVolSlider.value = 0.8
	EffectsVolSlider.value = 0.8
	ResolutionDropdown.select(2)
	FullscreenToggle.button_pressed = true
	VSyncToggle.button_pressed = true

#endregion

#region Debugging TODO: Delete Later!



#endregion
