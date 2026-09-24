extends Control

const TILE = preload("res://Scenes/tile.tscn")
var Tiles = []

var bFocused : bool = false

var TILE_WIDTH : int = 128
var TILE_HEIGHT : int = 128
const TILE_GAP : int = 5
const GRID_WIDTH : int = 5
const GRID_HEIGHT : int = 5
const GRID_PADDING : int = 20
@onready var TOTAL_GRID_WIDTH : int = $GridBackground.size.x
@onready var TOTAL_GRID_HEIGHT : int = $GridBackground.size.y
const TILE_COUNT : int = GRID_WIDTH * GRID_HEIGHT

var ActiveIndex : int = 0
var HintTitles : Array[String] = []

var CurrentHighlight : Constants.Highlight = Constants.Highlight.Inactive

func SetColumnInvalid(Index : int, Invalid : bool):
	for i in range(Index, TILE_COUNT, GRID_WIDTH):
		if Tiles[i].GetBlocked():
			break
		Tiles[i].SetInvalidWord(Invalid)
	
	# Grow up
	for i in range(Index, -1, -GRID_WIDTH):
		if Tiles[i].GetBlocked():
			break
		Tiles[i].SetInvalidWord(Invalid)

func SetRowInvalid(Index : int, Invalid : bool):
	var RowStart = Index - (Index % GRID_WIDTH) - 1
	var RowEnd = RowStart + GRID_WIDTH + 1
	
	for i in range(Index, RowEnd):
		if Tiles[i].GetBlocked():
			break
		Tiles[i].SetInvalidWord(Invalid)
	
	for i in range(Index, RowStart, -1):
		if Tiles[i].GetBlocked():
			break
		Tiles[i].SetInvalidWord(Invalid)
		
func SetColumnState(State):
	# Grow Down
	for i in range(ActiveIndex, TILE_COUNT, GRID_WIDTH):
		if Tiles[i].GetBlocked():
			break
		Tiles[i].SetState(State)
	
	# Grow up
	for i in range(ActiveIndex, -1, -GRID_WIDTH):
		if Tiles[i].GetBlocked():
			break
		Tiles[i].SetState(State)


func SetRowState(State):
	var RowStart = ActiveIndex - (ActiveIndex % GRID_WIDTH) - 1
	var RowEnd = RowStart + GRID_WIDTH + 1
	
	for i in range(ActiveIndex, RowEnd):
		if Tiles[i].GetBlocked():
			break
		Tiles[i].SetState(State)
	
	for i in range(ActiveIndex, RowStart, -1):
		if Tiles[i].GetBlocked():
			break
		Tiles[i].SetState(State)
		
func TileClicked(Index):
	# Deactive the old selected row or column
	if CurrentHighlight == Constants.Highlight.RowActive:
		var Row = ActiveIndex / GRID_HEIGHT
		for i in range(Row * GRID_WIDTH, Row * GRID_WIDTH + GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		var Column = ActiveIndex % GRID_HEIGHT
		for i in range(Column, TILE_COUNT, GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)

	# On click evaluate if the row or column should be highlighted
	if CurrentHighlight == Constants.Highlight.Inactive:
		CurrentHighlight = Constants.Highlight.RowActive
		bFocused = true
	elif ActiveIndex == Index:
		if CurrentHighlight == Constants.Highlight.RowActive:
			CurrentHighlight = Constants.Highlight.ColumnActive
		else:
			CurrentHighlight = Constants.Highlight.RowActive
	SetActive(Index)
	

func SetActive(Index):
	# Deactive the old selected tile
	Tiles[ActiveIndex].SetState(Constants.TileState.Inactive)
	
		# Deactive the old selected row or column
	if CurrentHighlight == Constants.Highlight.RowActive:
		var Row = ActiveIndex / GRID_HEIGHT
		for i in range(Row * GRID_WIDTH, Row * GRID_WIDTH + GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		var Column = ActiveIndex % GRID_HEIGHT
		for i in range(Column, TILE_COUNT, GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)
	
	ActiveIndex = Index
	
	# Highlight the new selected row or column
	if CurrentHighlight == Constants.Highlight.RowActive:
		SetRowState(Constants.TileState.WordActive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		SetColumnState(Constants.TileState.WordActive)

	Tiles[ActiveIndex].SetState(Constants.TileState.TileActive)

func HintFocused(Hint : String):
	if CurrentHighlight == Constants.Highlight.RowActive:
		var Row = ActiveIndex / GRID_HEIGHT
		for i in range(Row * GRID_WIDTH, Row * GRID_WIDTH + GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		var Column = ActiveIndex % GRID_HEIGHT
		for i in range(Column, TILE_COUNT, GRID_WIDTH):
			Tiles[i].SetState(Constants.TileState.Inactive)
	
	if Hint[-1] == "A":
		ActiveIndex = Thing[Hint].x + Thing[Hint].y * GRID_WIDTH
		SetRowState(Constants.TileState.HintActive)
		CurrentHighlight = Constants.Highlight.RowActive
	elif Hint[-1] == "D":
		ActiveIndex = Thing[Hint].x + Thing[Hint].y * GRID_WIDTH
		SetColumnState(Constants.TileState.HintActive)
		CurrentHighlight = Constants.Highlight.ColumnActive

func SaveCrossword():
	var Content = ""
	
	for i in range(TILE_COUNT):
		if i > 0 and i % GRID_WIDTH == 0:
			Content += "\n"
		
		if Tiles[i].GetBlocked():
			Content += "*"
			continue
		
		Content += Tiles[i].GetCharacter()
	
	Content += "\n"
	
	var Hints = $"../Hint".GetHints()
	
	for Hint in Hints:
		Content += ":" + Hint
	
	print(Content)
	
	var CrosswordName = "test"
	
	var file = FileAccess.open("user://" + CrosswordName + ".txt", FileAccess.WRITE)
	file.store_string(Content)

func SpawnGrid():
	TILE_WIDTH = (TOTAL_GRID_WIDTH - 2 * GRID_PADDING - (GRID_WIDTH - 1) * TILE_GAP) / GRID_WIDTH
	TILE_HEIGHT = (TOTAL_GRID_HEIGHT - 2 * GRID_PADDING - (GRID_HEIGHT - 1) * TILE_GAP) / GRID_HEIGHT
	
	# Get all the block tiles and scale them based on the current size of the tiles in the grid
	for child in get_parent().get_children():
		if child is BlockTileSpawn:
			child.scale.x *= TILE_WIDTH / 100.0
			child.scale.y *= TILE_HEIGHT / 100.0
	
	for i in range(TILE_COUNT):
		var new_tile : Tile = TILE.instantiate()
		add_child(new_tile)
		
		# This is probably not the nicest thing, I believe that this is what results in the pixelly look of the text on the tiles. Works for now
		new_tile.scale.x *= TILE_WIDTH / 100.0
		new_tile.scale.y *= TILE_HEIGHT / 100.0
		
		new_tile.position.x = $GridBackground.position.x + GRID_PADDING + (i % GRID_WIDTH) * (TILE_WIDTH + TILE_GAP) + TILE_WIDTH / 2.0
		new_tile.position.y = $GridBackground.position.y + GRID_PADDING + int(i / float(GRID_HEIGHT)) * (TILE_HEIGHT + TILE_GAP) + TILE_HEIGHT / 2.0

		new_tile.Index = i
		new_tile.Owner = self
		
		Tiles.append(new_tile)

var Thing : Dictionary[String, Vector2] = {}

func SetTileNumbers():
	for i in range(TILE_COUNT):
		Tiles[i].ClearWordNumber()
	
	HintTitles = []
	Thing = {}
	
	#var Number = 1
	var VerticalChecked = []
	var HorizontalChecked = []
	var GivenNumber = []
	
	for y in range(GRID_HEIGHT):
		for x in range(GRID_WIDTH):
			if Tiles[x + y * GRID_WIDTH].GetBlocked():
				continue
				
			var Number = GivenNumber.size() + 1
			
			# Vertical Check
			if not (y * GRID_WIDTH + x in VerticalChecked) and not (y * GRID_WIDTH + x in GivenNumber):
				var WordCount = 0
				for dy in range(y, GRID_HEIGHT):
					if Tiles[x + dy * GRID_WIDTH].GetBlocked():
						break
					WordCount += 1
				if WordCount > 1:
					Tiles[x + y * GRID_WIDTH].SetWordNumber(Number)
					GivenNumber.append(x + y * GRID_WIDTH)
					HintTitles.append(str(Number) + "D")
					Thing[str(Number) + "D"] = Vector2(x, y)
			
			# Mark this axis as considered in vertical
			for dy in range(y, GRID_HEIGHT):
				if Tiles[x + dy * GRID_WIDTH].GetBlocked():
					break
				VerticalChecked.append(x + dy * GRID_WIDTH)
			
			# Horizontal Check
			if not (y * GRID_WIDTH + x in HorizontalChecked):
				var WordCount = 0
				for dx in range(x, GRID_WIDTH):
					if Tiles[dx + y * GRID_WIDTH].GetBlocked():
						break
					WordCount += 1
				if WordCount > 1:
					if (y * GRID_WIDTH + x in GivenNumber):
						HintTitles.append(str(Number) + "A")
						Thing[str(Number) + "A"] = Vector2(x, y)
					else:
						Tiles[x + y * GRID_WIDTH].SetWordNumber(Number)
						GivenNumber.append(x + y * GRID_WIDTH)
						HintTitles.append(str(Number) + "A")
						Thing[str(Number) + "A"] = Vector2(x, y)
			
			# Mark this axis as considered horizontally
			for dx in range(x, GRID_WIDTH):
				if Tiles[dx + y * GRID_WIDTH].GetBlocked():
					break
				HorizontalChecked.append(dx + y * GRID_WIDTH)
			
			Number += 1

var WordList : PackedStringArray

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SpawnGrid()
	SetTileNumbers()
	$"../Hint".PopulateHintList(HintTitles)
	var file = FileAccess.open("res://words.txt", FileAccess.READ)
	var Words = file.get_as_text()
	WordList = Words.split("\n")
	
	# Make it lowercase so our comparisons work
	for i in range(WordList.size()):
		WordList[i] = WordList[i].to_lower()


func SetHintList():
	$"../Hint".PopulateHintList(HintTitles)

func ShowWordWarning(show : bool):
	if show:
		$NotWordWarning.show()
	else:
		$NotWordWarning.hide()

func ShowWinMessage(show : bool):
	if show:
		$WinMessage.show()
		$Button.visible = true
	else:
		$WinMessage.hide()
		$Button.visible = false

func EvaluateRow(CheckPoint : int):
	var RowStart = CheckPoint - (CheckPoint % GRID_WIDTH) - 1
	var RowEnd = RowStart + GRID_WIDTH + 1
	
	var Word = ""
	
	for i in range(CheckPoint + 1, RowEnd):
		if Tiles[i].GetBlocked():
			break
		if Tiles[i].GetCharacter() == "":
			return [false]
		Word += Tiles[i].GetCharacter()
	
	for i in range(CheckPoint, RowStart, -1):
		if Tiles[i].GetBlocked():
			break
		if Tiles[i].GetCharacter() == "":
			return [false]
		Word = Tiles[i].GetCharacter() + Word
	
	return [true, Word]

func EvaluateColumn(CheckPoint : int):
	var Word = ""
	# Grow Down
	for i in range(CheckPoint + GRID_WIDTH, TILE_COUNT, GRID_WIDTH):
		if Tiles[i].GetBlocked():
			break
		if Tiles[i].GetCharacter() == "":
			return [false]
		Word += Tiles[i].GetCharacter()
	
	# Grow up
	for i in range(CheckPoint, -1, -GRID_WIDTH):
		if Tiles[i].GetBlocked():
			break
		if Tiles[i].GetCharacter() == "":
			return [false]
		Word = Tiles[i].GetCharacter() + Word
	return [true, Word]

#Use THING, iterate over it and use the above functions, if all are true and the words are real then end game
func EvaluatePuzzle():
	ShowWordWarning(false)
	
	for HintTitle in Thing:
		#print(HintTitle)
		if HintTitle[-1] == "D":
			SetColumnInvalid(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH, false)
		elif HintTitle[-1] == "A":
			SetRowInvalid(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH, false)
	
	#print(Thing)
	var bDone : bool = true
	
	for HintTitle in Thing:
		#print(HintTitle)
		if HintTitle[-1] == "D":
			var Res = EvaluateColumn(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH)
			#print(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH)
			if Res[0]:
				print(Res[1].to_lower())
				#if not (Res[1].to_lower() in WordList):
				if not WordList.has(Res[1].to_lower()):
					ShowWordWarning(true)
					print("SHOW WARNING!")
					#SetColumnState(Constants.TileState.InvalidWord)
					#Tiles[Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH].SetInvalidWord(true)
					SetColumnInvalid(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH, true)
					bDone = false
			else:
				bDone = false
				
		elif HintTitle[-1] == "A":
			#print(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH)
			var Res = EvaluateRow(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH)
			if Res[0]:
				print(Res[1].to_lower())
				if not WordList.has(Res[1].to_lower()):
				#if not (Res[1].to_lower() in WordList):
					ShowWordWarning(true)
					#SetRowState(Constants.TileState.InvalidWord)
					#Tiles[Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH].SetInvalidWord(true)
					SetRowInvalid(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH, true)
					print("SHOW WARNING!")
					bDone = false
			else:
				bDone = false
	
	ShowWinMessage(bDone)
	return bDone

func _input(event: InputEvent) -> void:
	if bFocused and event is InputEventKey and event.is_pressed() and !event.is_echo():
		var label = DisplayServer.keyboard_get_label_from_physical(event.physical_keycode)
		if label == 4194308:
			if Tiles[ActiveIndex].GetCharacter() != "":
				Tiles[ActiveIndex].SetCharacter("")
				if EvaluatePuzzle():
					print("Puzzle Done!")
				return
			var PrevTile = ActiveIndex
			if CurrentHighlight == Constants.Highlight.RowActive or CurrentHighlight == Constants.Highlight.ColumnActive:
				if CurrentHighlight == Constants.Highlight.RowActive:
					PrevTile -= 1
				if CurrentHighlight == Constants.Highlight.ColumnActive:
					PrevTile -= GRID_WIDTH
			SetActive(PrevTile)
			Tiles[ActiveIndex].SetCharacter("")
			EvaluatePuzzle()
		if 65 <= label and label <= 90:
			var NextTile = ActiveIndex
			if CurrentHighlight == Constants.Highlight.RowActive or CurrentHighlight == Constants.Highlight.ColumnActive:
				Tiles[ActiveIndex].SetCharacter(OS.get_keycode_string(label))
				
				EvaluatePuzzle()
				
				# Move to next tile
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
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var Min = position
		var Max = position + $GridBackground.size
		#var Min = position - Vector2(TOTAL_GRID_WIDTH / 2 + (TILE_WIDTH/2), TOTAL_GRID_HEIGHT / 2 + (TILE_WIDTH/2))
		#var Max = position + Vector2(TOTAL_GRID_WIDTH / 2 - (TILE_HEIGHT/2), TOTAL_GRID_HEIGHT / 2 - (TILE_HEIGHT/2))
		var Mousepos = get_viewport().get_mouse_position()
		
		var bWithinX = Min.x <= Mousepos.x and Mousepos.x <= Max.x
		var bWithinY = Min.y <= Mousepos.y and Mousepos.y <= Max.y
		var bWithin = bWithinX and bWithinY
		
		if (not bWithin):
			bFocused = false
			if CurrentHighlight == Constants.Highlight.RowActive:
				SetRowState(Constants.TileState.Inactive)
			elif CurrentHighlight == Constants.Highlight.ColumnActive:
				SetColumnState(Constants.TileState.Inactive)
			CurrentHighlight = Constants.Highlight.Inactive


func _on_button_button_down() -> void:
	SaveCrossword()
