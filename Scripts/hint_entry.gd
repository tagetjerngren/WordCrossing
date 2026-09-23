extends HBoxContainer

func SetTitle(Title : String):
	$Label.text = Title

# This, while a little weird, seems to be the exact behavior I want
# Any click outside of the text box deselects it
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		$TextEdit.release_focus()
