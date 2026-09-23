extends HBoxContainer

func SetTitle(Title : String):
	$Label.text = Title

var Owner

func SetOwner(HintOwner):
	Owner = HintOwner

# This, while a little weird, seems to be the exact behavior I want
# Any click outside of the text box deselects it
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		$TextEdit.release_focus()

func _on_text_edit_focus_entered() -> void:
	print($Label.text)
	Owner.HintFocused($Label.text)
