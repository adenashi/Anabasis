class_name SceneTransitioner extends ColorRect


#region Constants

const FADE_SPEED = 0.7
const TRANS_SPEED = 0.2

#endregion

#region Exports

@export var LoadingLabel : Label
@export var HintLabel : Label

@export_multiline var Hints : Array[String] = []

@export_group("Asi")
@export_subgroup("Sitting")
@export var AsiSitting : TextureRect
@export var LightShaft : PointLight2D
@export_subgroup("With Sword")
@export var AsiWithSword : TextureRect
@export var AsiCover : TextureRect
@export var AsiLightMasks : Array[Texture] = []
@export_group("Rufus")
@export var Rufus : TextureRect
@export var RufusPanel : PanelContainer
@export var RufusTip : Label
@export_multiline var RufusDialogue : Array[String] = []

#endregion

#region Private Variables

var sceneToLoad : String
var loadTween : Tween
var rufusTween : Tween

#endregion

#region Loading Scenes

func go_to_scene(newScene : String) -> void:
	sceneToLoad = newScene
	self.modulate.a = 1.0
	self.show()
	
	HintLabel.text = Hints.pick_random()
	if loadTween:
		loadTween.kill()
	
	loadTween = create_tween()
	loadTween.tween_property(HintLabel, "modulate:a", 1.0, FADE_SPEED)
	loadTween.tween_callback(load_scene)
	loadTween.tween_property(HintLabel, "modulate:a", 0.0, TRANS_SPEED)
	loadTween.tween_interval(1.0)
	loadTween.tween_property(self, "modulate:a", 0.0, FADE_SPEED)
	loadTween.tween_callback(self.hide)
	await loadTween.finished
	loadTween = null
	


func load_scene() -> void:
	get_tree().change_scene_to_file(sceneToLoad)

#endregion

#region Menu Transitions

func transition_to_menu(menu : Control) -> void:
	if loadTween:
		loadTween.kill()
	
	self.show()
	loadTween = create_tween()
	loadTween.tween_property(self, "modulate:a", 1.0, TRANS_SPEED)
	loadTween.tween_callback(menu.show)
	loadTween.tween_property(self, "modulate:a", 0.0, TRANS_SPEED)
	loadTween.tween_callback(self.hide)
	await loadTween.finished
	loadTween = null


func transition_from_menu(menu : Control) -> void:
	if loadTween:
		loadTween.kill()
	
	self.show()
	loadTween = create_tween()
	loadTween.tween_property(self, "modulate:a", 1.0, TRANS_SPEED)
	loadTween.tween_callback(menu.hide)
	loadTween.tween_property(self, "modulate:a", 0.0, TRANS_SPEED)
	loadTween.tween_callback(self.hide)
	await loadTween.finished
	loadTween = null

#endregion

#region Fading Tweens

func fade_in() -> void:
	if loadTween:
		loadTween.kill()
	
	loadTween.tween_property(self, "modulate:a", 0.0, TRANS_SPEED)
	loadTween.tween_callback(self.hide)
	await loadTween.finished
	loadTween = null


func fade_out() -> void:
	if loadTween:
		loadTween.kill()
	
	self.show()
	loadTween = create_tween()
	loadTween.tween_property(self, "modulate:a", 1.0, TRANS_SPEED)
	await loadTween.finished
	loadTween = null

#endregion

#region Looping Tweens

func loop_loading_label() -> void:
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel().set_loops()
	tween.tween_property(LoadingLabel, "modulate:a", 0.0, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(LoadingLabel, "modulate:a", 1.0, 1.0)


func rufus_float() -> void:
	if rufusTween:
		rufusTween.kill()
	
	rufusTween = Rufus.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel().set_loops()
	rufusTween.tween_property(Rufus, "position:y", Rufus.position.y - 7.0, 0.8)
	rufusTween.tween_property(Rufus, "rotation_degrees", 7.0, 0.8)
	rufusTween.chain()
	rufusTween.tween_interval(0.3)
	rufusTween.set_parallel()
	rufusTween.tween_property(Rufus, "position:y", Rufus.position.y + 7.0, 0.8)
	rufusTween.tween_property(Rufus, "rotation_degrees", -7.0, 0.8)

#endregion

#region Moving Towards Game

func transition_to_stage() -> void:
	sceneToLoad = "res://game/game.tscn"
	Rufus.show()
	rufus_float()
	self.modulate.a = 0.0
	AsiCover.texture = AsiLightMasks[Global.StagesToClear - 1]
	RufusTip.text = Hints.pick_random()
	self.show()
	
	if loadTween:
		loadTween.kill()
	
	loadTween = create_tween()
	loadTween.tween_property(self, "modulate:a", 1.0, FADE_SPEED)
	loadTween.tween_property(AsiWithSword, "modulate:a", 1.0, TRANS_SPEED)
	loadTween.tween_callback(load_scene)
	loadTween.tween_property(RufusPanel, "modulate:a", 1.0, TRANS_SPEED)
	loadTween.tween_interval(3.0)
	loadTween.tween_property(self, "modulate:a", 0.0, FADE_SPEED)
	loadTween.tween_callback(self.hide)
	await loadTween.finished
	loadTween = null
	AsiWithSword.modulate.a = 0.0
	Rufus.hide()
	RufusPanel.modulate.a = 0.0
	rufusTween.kill()

#endregion

#region Transition To Victory

func transition_to_victory() -> void: #TODO : Add another Asi Image Here.
	sceneToLoad = "uid://box7qgq2qvf7x"
	
	self.show()
	loadTween = create_tween()
	loadTween.tween_property(self, "modulate:a", 1.0, FADE_SPEED)
	loadTween.tween_callback(load_scene)
	loadTween.tween_interval(1.0)
	loadTween.tween_property(self, "modulate:a", 0.0, FADE_SPEED)
	loadTween.tween_callback(self.hide)
	await loadTween.finished
	loadTween = null

#endregion

#region Transition To Main Menu

func transition_to_main_menu() -> void:
	sceneToLoad = "uid://btu7wqw3l2le1"
	Rufus.show()
	rufus_float()
	if loadTween:
		loadTween.kill()
	AsiSitting.modulate.a = 1.0
	AsiSitting.show()
	
	self.show()
	loadTween = create_tween()
	loadTween.tween_property(self, "modulate:a", 1.0, FADE_SPEED)
	loadTween.tween_callback(load_scene)
	loadTween.tween_interval(FADE_SPEED * 2)
	loadTween.set_parallel()
	loadTween.tween_property(AsiSitting, "modulate:a", 0.5, 1.0)
	loadTween.tween_property(AsiSitting, "scale", Vector2(0.5,0.5), 1.0)
	loadTween.tween_property(AsiSitting, "position", Vector2.ZERO, 1.0)
	loadTween.tween_property(Rufus, "modulate:a", 0.0, 1.0)
	loadTween.chain()
	loadTween.tween_property(self, "modulate:a", 0.0, FADE_SPEED)
	loadTween.tween_callback(self.hide)
	await loadTween.finished
	loadTween = null
	AsiSitting.hide()
	AsiSitting.modulate.a = 0.0
	AsiSitting.scale = Vector2.ONE
	AsiSitting.position = Vector2(158.0,0.0)
	Rufus.hide()
	Rufus.modulate.a = 1.0
	rufusTween.kill()

#endregion

#region Transition to New Game

func transition_to_new_game() -> void:
	sceneToLoad = "uid://bcxakmx7kigwa"
	if loadTween:
		loadTween.kill()
	
	self.show()
	loadTween = create_tween()
	loadTween.tween_property(self, "modulate:a", 1.0, FADE_SPEED)
	loadTween.tween_callback(load_scene)
	loadTween.tween_interval(3.0)
	loadTween.tween_property(AsiSitting, "modulate:a", 1.0, TRANS_SPEED)
	loadTween.tween_property(self, "modulate:a", 0.0, FADE_SPEED)
	loadTween.tween_callback(self.hide)
	await loadTween.finished
	loadTween = null
	Dispatch.ShowAsi.emit()
	AsiSitting.modulate.a = 0.0

#endregion

#region Debugging TODO: Delete Later!



#endregion
