extends Control

const HINT_ENTRY = preload("res://Scenes/hint_entry.tscn")
# Called when the node enters the scene tree for the first time.

var Entries = []

func PopulateHintList(strings : Array[String]):
	for Entry in Entries:
		Entry.queue_free()
	Entries = []
	
	for i in strings:
		var Entry = HINT_ENTRY.instantiate()
		$ColorRect/ScrollContainer/VBoxContainer.add_child(Entry)
		Entry.SetTitle(i)
		Entry.SetOwner(self)
		Entries.append(Entry)

func GetHints() -> Array[String]:
	var Hints : Array[String] = []
	
	for Entry in Entries:
		Hints.append(Entry.GetHint())
	
	return Hints

func HintFocused(Hint : String):
	$"../Grid".HintFocused(Hint)
