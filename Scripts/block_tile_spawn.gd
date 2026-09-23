class_name BlockTileSpawn

extends Area2D

var BLOCK_TILE = preload("res://Scenes/block_tile.tscn")

@export var AvailableTiles : int = 6

func UpdateAvailableTilesText():
	$ColorRect2/Label.text = str(AvailableTiles)
	

func _ready() -> void:
	UpdateAvailableTilesText()
	
func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and AvailableTiles > 0:
		var block_tile : BlockTile = BLOCK_TILE.instantiate()
		get_parent().add_child(block_tile)
		block_tile.global_position = get_viewport().get_mouse_position()
		block_tile.bHeld = true
		block_tile.scale = scale
		block_tile.Offset = Vector2()
		block_tile.Spawner = self
		
		AvailableTiles -= 1;
		UpdateAvailableTilesText()
