class_name TabButton extends Button

#region Initialization

func _ready() -> void:
	mouse_entered.connect(func(): AM.play_sfx("UI", "Hover"))
	toggled.connect(on_button_toggled)

#endregion

#region Input Event Functions

func on_button_toggled(is_on : bool) -> void:
	AM.play_sfx("UI", "Click")
	if is_on:
		theme_type_variation = "TabButtonSelected"
	else:
		theme_type_variation = "TabButtonNormal"

#endregion

#region Debugging TODO: Delete Later!



#endregion
