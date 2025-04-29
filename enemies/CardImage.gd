extends TextureRect


#region Constants

const ENEMY_TOOLTIP = preload("res://enemies/enemy_hud_tooltip.tscn")

#endregion

#region Aesthetics

func _make_custom_tooltip(for_text: String) -> Object:
	var tooltip = ENEMY_TOOLTIP.instantiate()
	tooltip.get_child(0).text = for_text
	return tooltip

#endregion

#region Debugging TODO: Delete Later!



#endregion
