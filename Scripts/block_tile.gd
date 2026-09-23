extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

var bHeld : bool = false
var Offset : Vector2 
var BlockedTile : Tile

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if bHeld:
		position = get_global_mouse_position() - Offset


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		bHeld = true
		Offset = get_global_mouse_position() - position
		if BlockedTile != null:
			BlockedTile.SetBlocked(false)
	
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
			closest_tile.SetBlocked(true)
			#closest_tile.Owner.SetTileNumbers()
			#closest_tile.Owner.SetHintList()
			BlockedTile = closest_tile
		
		$"../Grid".SetTileNumbers()
		$"../Grid".SetHintList()
