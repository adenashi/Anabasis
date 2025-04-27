class_name GameStarter extends Control

#region Exports

@export var InnerControl : Control
@export var NumberLabel : Label
@export var StageLabel : Label
@export var MinusButton : TextureButton
@export var PlusButton : TextureButton
@export var Asi : TextureRect
@export var LightShaft : PointLight2D
@export var AsiCover : TextureRect
@export var CoverImages : Array[Texture] = []
@export var AsiLight : PointLight2D
@export var LightMasks : Array[Texture] = []
@export var Rufus : TextureRect
@export var Sword : TextureRect

#endregion

#region Private Variables

var NumberOfLevels : int :
	set(value):
		NumberOfLevels = value
		set_number_label()

#endregion

#region Initialization

func _ready() -> void:
	Dispatch.ShowAsi.connect(move_asi)
	NumberOfLevels = 1

#endregion

#region Button Press Methods

func on_one_button_pressed(_on : bool) -> void:
	NumberOfLevels = 1


func on_three_button_pressed(_on : bool) -> void:
	NumberOfLevels = 3


func on_five_button_pressed(_on : bool) -> void:
	NumberOfLevels = 5


func on_ten_button_pressed(_on : bool) -> void:
	NumberOfLevels = 10


func on_fifteen_button_pressed(_on : bool) -> void:
	NumberOfLevels = 15


func on_twenty_two_button_pressed(_on : bool) -> void:
	NumberOfLevels = 20


func on_minus_button_pressed() -> void:
	NumberOfLevels -= 1
	if NumberOfLevels < 1:
		NumberOfLevels = 1
		MinusButton.disabled = true
	else:
		MinusButton.disabled = false
	PlusButton.disabled = false


func on_plus_button_pressed() -> void:
	NumberOfLevels += 1
	if NumberOfLevels > 20:
		NumberOfLevels = 20
		PlusButton.disabled = true
	else:
		PlusButton.disabled = false
	MinusButton.disabled = false


func set_number_label() -> void:
	if NumberOfLevels > 20 or NumberOfLevels < 1:
		return
	NumberLabel.text = str(NumberOfLevels)
	AsiCover.texture = CoverImages[NumberOfLevels - 1]
	AsiLight.texture = LightMasks[NumberOfLevels - 1]
	if NumberOfLevels > 1:
		StageLabel.text = "Stages"
	else:
		StageLabel.text = "Stage"


func on_confirm_button_pressed() -> void:
	Global.StagesToClear = NumberOfLevels
	await animate_confirmation()
	GUI.Transitioner.transition_to_stage()


func on_main_menu_button_pressed() -> void:
	GUI.Transitioner.transition_to_main_menu()

#endregion

#region Asi Transition
func move_asi() -> void:
	var tween = Asi.create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(Asi, "scale", Vector2(1.0,1.0), 0.8)
	tween.tween_property(Asi, "position", Vector2(158.0,0.0), 0.8)
	tween.tween_property(Asi, "self_modulate:a", 1.0, 0.8)
	tween.tween_property(LightShaft, "position", Vector2(960.0,550.0), 0.8)
	tween.chain()
	tween.tween_property(Rufus, "modulate:a", 1.0,0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(InnerControl, "modulate:a", 1.0, 0.3).set_trans(Tween.TRANS_SINE)
	await tween.finished
	AsiLight.show()


func animate_confirmation() -> void:
	var tween = Sword.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(InnerControl.hide)
	tween.tween_property(Sword, "position", Vector2(1270.0,56.0), 0.2)
	tween.tween_interval(1.0)
	await tween.finished

#endregion

#region Debugging TODO: Delete Later!



#endregion
