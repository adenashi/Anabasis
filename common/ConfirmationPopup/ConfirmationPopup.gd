class_name ConfirmationPopup extends Control


#region Exports

@export_group("UI")
@export var Header : Label
@export var Body : Label
@export var ConfirmButton : Button
@export var CancelButton : Button

#endregion

#region Private Variables

var confirm : Callable
var cancel : Callable

#endregion

#region Input Event Functions

func get_confirmation(header : String, message : String, onConfirm : Callable, onCancel : Callable, ConfirmText : String = "Confirm", CancelText : String = "Cancel") -> void:
	Header.text = header
	Body.text = message
	if confirm:
		ConfirmButton.pressed.disconnect(confirm)
	if cancel:
		CancelButton.pressed.disconnect(cancel)
	
	confirm = onConfirm
	ConfirmButton.text = ConfirmText.to_upper()
	ConfirmButton.pressed.connect(confirm)
	
	cancel = onCancel
	CancelButton.text = CancelText.to_upper()
	CancelButton.pressed.connect(cancel)
	show()

#endregion

#region Debugging TODO: Delete Later!



#endregion
