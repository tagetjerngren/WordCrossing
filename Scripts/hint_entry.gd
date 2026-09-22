extends HBoxContainer

func SetTitle(Title : String):
	$Label.text = Title

func Unfocus():
	$TextEdit.release_focus()
