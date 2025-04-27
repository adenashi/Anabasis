class_name MainMenuButton extends Button


#region Initialization

func _ready() -> void:
	pass

#endregion

#region Input Event Functions

func on_mouse_enter() -> void:
	theme_type_variation = "TabButtonSelected"


func on_mouse_exit() -> void:
	theme_type_variation = "TabButtonNormal"


func on_focus_enter() -> void:
	theme_type_variation = "TabButtonSelected"


func on_focus_exit() -> void:
	theme_type_variation = "TabButtonNormal"

#endregion

#region Debugging TODO: Delete Later!



#endregion
