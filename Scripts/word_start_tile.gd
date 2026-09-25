class_name WordStartTile

extends Area2D

var bHeld : bool = false
var CoveredTile : Tile 
var Spawner : WordStartTileSpawn
var CurrentDirection = Constants.Highlight.ColumnActive

@onready var Grid = $"../WordCrossingManager/Grid"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if bHeld:
		position = get_global_mouse_position()
		
		# Gross way to remove focus from the grid while tile is held
		Grid.bFocused = false
		Grid.SetRowState(Constants.Highlight.Inactive)
		Grid.SetColumnState(Constants.Highlight.Inactive)
		
		if Input.is_action_just_pressed("RotateWordStartTile"):
			if CurrentDirection == Constants.Highlight.ColumnActive:
				rotate(-PI / 2)
				CurrentDirection = Constants.Highlight.RowActive
			elif CurrentDirection == Constants.Highlight.RowActive:
				rotate(PI / 2)
				CurrentDirection = Constants.Highlight.ColumnActive

func DeleteSelf():
	Spawner.AvailableTiles += 1
	Spawner.UpdateAvailableTilesText()
	queue_free()

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		bHeld = true
		if CoveredTile != null:
			CoveredTile.SetWordStart(false, Constants.Highlight.Inactive)
	
	if event is InputEventMouseButton and event.is_released():
		bHeld = false
		
		var overlapping_tiles = get_overlapping_areas()
		
		var RemoveIndices : Array[int] = []
		
		for i in range(overlapping_tiles.size()):
			if not overlapping_tiles[i] is Tile:
				RemoveIndices.append(i)
		RemoveIndices.reverse()
		for Index in RemoveIndices:
			overlapping_tiles.remove_at(Index)
		
		if overlapping_tiles.size() > 0:
			var closest_tile = overlapping_tiles[0]
			var distance = overlapping_tiles[0].global_position.distance_to(position)
			for tile in overlapping_tiles:
				if tile.global_position.distance_to(position) < distance:
					closest_tile = tile
					distance = tile.global_position.distance_to(position)
			global_position = closest_tile.global_position
			closest_tile.SetWordStart(true, CurrentDirection)
			CoveredTile = closest_tile
		else:
			DeleteSelf()
		
		Grid.EvaluatePuzzle()
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		DeleteSelf()
		Grid.EvaluatePuzzle()
