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
		#$ColorRect/VBoxContainer.add_child(Entry)
		$ColorRect/ScrollContainer/VBoxContainer.add_child(Entry)
		#$ColorRect/GridContainer.add_child(Entry)
		Entry.SetTitle(i)
		Entries.append(Entry)

func UnfocusList():
	for Entry in Entries:
		Entry.Unfocus()

func _ready() -> void:
	pass
	#PopulateHintList(["1A", "1D", "2A", "2D"])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
