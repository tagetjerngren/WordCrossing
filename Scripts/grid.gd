extends Node2D

const TILE = preload("res://Scenes/tile.tscn")
var Tiles = []

const TILE_WIDTH : int = 128
const TILE_HEIGHT : int = 128
const TILE_GAP : int = 2
const GRID_WIDTH : int = 5
const GRID_HEIGHT : int = 5
const TOTAL_GRID_WIDTH : int = GRID_WIDTH * (TILE_WIDTH + TILE_GAP)
const TOTAL_GRID_HEIGHT : int = GRID_HEIGHT * (TILE_HEIGHT + TILE_GAP)
const TILE_COUNT = GRID_WIDTH * GRID_HEIGHT

var ActiveIndex : int = 0

var CurrentHighlight : Constants.Highlight = Constants.Highlight.Inactive

func SetColumnState(State):
	var Column = ActiveIndex % GRID_HEIGHT
	for i in range(Column, TILE_COUNT, GRID_WIDTH):
		Tiles[i].SetState(State)

func SetRowState(State):
	var Row = floor(ActiveIndex / GRID_HEIGHT)
	for i in range(Row * GRID_WIDTH, Row * GRID_WIDTH + GRID_WIDTH):
		Tiles[i].SetState(State)
		
func TileClicked(Index):
	# Deactive the old selected row or column
	if CurrentHighlight == Constants.Highlight.RowActive:
		var Row = floor(ActiveIndex / GRID_HEIGHT)
		for i in range(Row * GRID_WIDTH, Row * GRID_WIDTH + GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		var Column = ActiveIndex % GRID_HEIGHT
		for i in range(Column, TILE_COUNT, GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)

	# On click evaluate if the row or column should be highlighted
	if CurrentHighlight == Constants.Highlight.Inactive:
		CurrentHighlight = Constants.Highlight.RowActive
	elif ActiveIndex == Index:
		if CurrentHighlight == Constants.Highlight.RowActive:
			CurrentHighlight = Constants.Highlight.ColumnActive
		else:
			CurrentHighlight = Constants.Highlight.RowActive
	SetActive(Index)
	
# Split this into functions that work on click and on type
# And one that just deals with updating the proper data
func SetActive(Index):
	# Deactive the old selected tile
	Tiles[ActiveIndex].SetState(Constants.TileState.Inactive)
	
		# Deactive the old selected row or column
	if CurrentHighlight == Constants.Highlight.RowActive:
		var Row = floor(ActiveIndex / GRID_HEIGHT)
		for i in range(Row * GRID_WIDTH, Row * GRID_WIDTH + GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		var Column = ActiveIndex % GRID_HEIGHT
		for i in range(Column, TILE_COUNT, GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)
	
	ActiveIndex = Index
	
	# Highlight the new selected row or column
	if CurrentHighlight == Constants.Highlight.RowActive:
		var Row = floor(ActiveIndex / GRID_HEIGHT)
		#print(Row)
		for i in range(Row * GRID_WIDTH, Row * GRID_WIDTH + GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.WordActive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		var Column = ActiveIndex % GRID_HEIGHT
		#print(Column)
		for i in range(Column, TILE_COUNT, GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.WordActive)

	Tiles[ActiveIndex].SetState(Constants.TileState.TileActive)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(TILE_COUNT):
		#print(i)
		var new_tile = TILE.instantiate()
		add_child(new_tile)
		new_tile.position.x += (i % GRID_WIDTH) * (TILE_WIDTH + TILE_GAP) - TOTAL_GRID_WIDTH / 2
		new_tile.position.y += floor(i / GRID_HEIGHT) * (TILE_HEIGHT + TILE_GAP) - TOTAL_GRID_HEIGHT / 2

		new_tile.Index = i
		new_tile.Owner = self
		
		Tiles.append(new_tile)

func _input(event: InputEvent) -> void:
	#if event is InputEventKey and !event.is_echo() and !event.is_released():
	#print(!event.is_echo())
	if event is InputEventKey and event.is_pressed() and !event.is_echo():
		var label = DisplayServer.keyboard_get_label_from_physical(event.physical_keycode)
		#print(label)
		if label == 4194308:
			#print(Tiles[ActiveIndex].GetCharacter())
			if Tiles[ActiveIndex].GetCharacter() != "":
				Tiles[ActiveIndex].SetCharacter("")
				return
			var PrevTile = ActiveIndex
			if CurrentHighlight == Constants.Highlight.RowActive or CurrentHighlight == Constants.Highlight.ColumnActive:
				if CurrentHighlight == Constants.Highlight.RowActive:
					PrevTile -= 1
				if CurrentHighlight == Constants.Highlight.ColumnActive:
					PrevTile -= GRID_WIDTH
					#if NextTile >= TILE_COUNT:
						#NextTile -= (TILE_COUNT - 1)
			SetActive(PrevTile)
			Tiles[ActiveIndex].SetCharacter("")
		if 65 <= label and label <= 90:
			var NextTile = ActiveIndex
			if CurrentHighlight == Constants.Highlight.RowActive or CurrentHighlight == Constants.Highlight.ColumnActive:
				Tiles[ActiveIndex].SetCharacter(OS.get_keycode_string(label))
				if CurrentHighlight == Constants.Highlight.RowActive:
					NextTile += 1
					if NextTile >= TILE_COUNT:
						NextTile = 0
						SetRowState(Constants.Highlight.Inactive)
						CurrentHighlight = Constants.Highlight.ColumnActive
				elif CurrentHighlight == Constants.Highlight.ColumnActive:
					NextTile += GRID_WIDTH
					if NextTile >= TILE_COUNT:
						NextTile -= (TILE_COUNT - 1)
			SetActive(NextTile)
			
		#Tiles[ActiveIndex].SetCharacter(OS.get_keycode_string(label))
