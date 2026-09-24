class_name WordStartTileSpawn

extends Area2D

var WORD_START_TILE = preload("res://Scenes/word_start_tile.tscn")

@export var AvailableTiles : int = 3

func UpdateAvailableTilesText():
	$ColorRect5/Label.text = str(AvailableTiles)
	if AvailableTiles == 0:
		#$ColorRect.color = Color(0.166, 0.166, 0.166, 1.0)
		$ColorRect5.color = Color(0.753, 0.0, 0.0, 1.0)
	else:
		#$ColorRect.color = Color(0.0, 0.0, 0.0, 1.0)
		$ColorRect5.color = Color(0.243, 0.243, 0.243, 1.0)
		
func _ready() -> void:
	UpdateAvailableTilesText()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and AvailableTiles > 0:
		var word_start_tile : WordStartTile = WORD_START_TILE.instantiate()
		get_parent().add_child(word_start_tile)
		word_start_tile.global_position = get_viewport().get_mouse_position()
		word_start_tile.bHeld = true
		word_start_tile.scale = scale
		#word_start_tile.Offset = Vector2()
		word_start_tile.Spawner = self
		
		AvailableTiles -= 1;
		UpdateAvailableTilesText()
