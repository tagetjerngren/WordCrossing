extends Control

@export var LevelLayout : String
@export var Grid_Size : int = 5
@export var NextLevel : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Grid.GRID_WIDTH = Grid_Size
	$Grid.GRID_HEIGHT = Grid_Size
	$Grid.TILE_COUNT = Grid_Size * Grid_Size
	$Grid.SpawnGrid()
	$Grid.LoadGrid(LevelLayout)
	$Grid.SetTileNumbers()
	
	#if (NextLevel != null):
		#get_tree().change_scene_to_packed(NextLevel)


func _on_grid_game_won() -> void:
	#print("Here!")
	if (NextLevel != null):
		get_tree().change_scene_to_packed(NextLevel)
