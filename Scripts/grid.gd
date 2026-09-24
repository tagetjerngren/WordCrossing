extends Control

const TILE = preload("res://Scenes/tile.tscn")
var Tiles = []

var bFocused : bool = false

var TILE_WIDTH : int = 128
var TILE_HEIGHT : int = 128
const TILE_GAP : int = 5
@export var GRID_WIDTH : int = 5
@export var GRID_HEIGHT : int = 5
const GRID_PADDING : int = 20
@onready var TOTAL_GRID_WIDTH : int = $GridBackground.size.x
@onready var TOTAL_GRID_HEIGHT : int = $GridBackground.size.y
var TILE_COUNT : int = GRID_WIDTH * GRID_HEIGHT

var ActiveIndex : int = -1
var HintTitles : Array[String] = []

#signal game_won
signal GameWon

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
		SetRowState(Constants.Highlight.Inactive)
		#var Row = ActiveIndex / GRID_HEIGHT
		#for i in range(Row * GRID_WIDTH, Row * GRID_WIDTH + GRID_WIDTH):
			#Tiles[i].SetState(Constants.TileState.Inactive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		SetColumnState(Constants.Highlight.Inactive)
		#var Column = ActiveIndex % GRID_HEIGHT
		#for i in range(Column, TILE_COUNT, GRID_WIDTH):
			#Tiles[i].SetState(Constants.TileState.Inactive)

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
	if ActiveIndex != -1:
		Tiles[ActiveIndex].SetState(Constants.TileState.Inactive)
	
		# Deactive the old selected row or column
	if CurrentHighlight == Constants.Highlight.RowActive:
		SetRowState(Constants.Highlight.Inactive)
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		SetColumnState(Constants.Highlight.Inactive)
	
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
	
	for child in get_parent().get_parent().get_children():
		if child is BlockTileSpawn:
			child.scale.x *= TILE_WIDTH / 100.0
			child.scale.y *= TILE_HEIGHT / 100.0
		if child is WordStartTileSpawn:
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

func LoadGrid(Content : String):
	for i in range(len(Content)):
		if Content[i] == "*":
			Tiles[i].SetBlocked(true)

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
	#SpawnGrid()
	#SetTileNumbers()
	##$"../Hint".PopulateHintList(HintTitles)
	#print("Here!")
	var file = FileAccess.open("res://words.txt", FileAccess.READ)
	var Words = file.get_as_text()
	WordList = Words.split("\n")
	
	# Make it lowercase so our comparisons work
	for i in range(WordList.size()):
		WordList[i] = WordList[i].to_lower()


func SetHintList():
	if $"../Hint":
		$"../Hint".PopulateHintList(HintTitles)

func ShowWordWarning(show : bool):
	if show:
		$NotWordWarning.show()
	else:
		$NotWordWarning.hide()

func ShowWinMessage(show : bool):
	if show:
		$NextLevelButton.visible = true
		$WinMessage.show()
		$Button.visible = true
	else:
		$WinMessage.hide()
		$Button.visible = false
		$NextLevelButton.visible = false

func EvaluateRow(CheckPoint : int):
	var RowStart = CheckPoint - (CheckPoint % GRID_WIDTH) - 1
	var RowEnd = RowStart + GRID_WIDTH + 1
	
	var Word = ""
	
	for i in range(CheckPoint + 1, RowEnd):
		if Tiles[i].GetBlocked():
			break
		if Tiles[i].GetCharacter() == "":
			return [false, false]
		
		var Res = Tiles[i].GetWordStart()
		var bWordStart = Res[0]
		var WordDirection = Res[1]
		if bWordStart and WordDirection == Constants.Highlight.RowActive:
			Word += ","
		
		Word += Tiles[i].GetCharacter()
	
	for i in range(CheckPoint, RowStart, -1):
		if Tiles[i].GetBlocked():
			break
		if Tiles[i].GetCharacter() == "":
			return [false, false]
		
		var Res = Tiles[i].GetWordStart()
		var bWordStart = Res[0]
		var WordDirection = Res[1]
		if bWordStart and WordDirection == Constants.Highlight.RowActive:
			Word += ","
			
		Word = Tiles[i].GetCharacter() + Word
	
	var bWordsInWordList = true
	var Words = Word.split(",")
	for w in Words:
		if not (WordList.has(w.to_lower())):
			bWordsInWordList = false
	
	return [true, bWordsInWordList]

func EvaluateColumn(CheckPoint : int):
	var Word = ""
	# Grow Down
	for i in range(CheckPoint + GRID_WIDTH, TILE_COUNT, GRID_WIDTH):
		if Tiles[i].GetBlocked():
			break
		if Tiles[i].GetCharacter() == "":
			return [false, false]
		
		# If it's a word start add a comma
		var Res = Tiles[i].GetWordStart()
		var bWordStart = Res[0]
		var WordDirection = Res[1]
		if bWordStart and WordDirection == Constants.Highlight.ColumnActive:
			Word += ","
			
		Word += Tiles[i].GetCharacter()
	
	# Grow up
	for i in range(CheckPoint, -1, -GRID_WIDTH):
		if Tiles[i].GetBlocked():
			break
		if Tiles[i].GetCharacter() == "":
			return [false, false]
		
		# If it's a word start add a comma
		var Res = Tiles[i].GetWordStart()
		var bWordStart = Res[0]
		var WordDirection = Res[1]
		if bWordStart and WordDirection == Constants.Highlight.ColumnActive:
			Word += ","
			
		Word = Tiles[i].GetCharacter() + Word
	
	#print(Word)
	var bWordsInWordList = true
	var Words = Word.split(",")
	#print(Words)
	for w in Words:
		if not (WordList.has(w.to_lower())):
			bWordsInWordList = false
	
	return [true, bWordsInWordList]

#Use THING, iterate over it and use the above functions, if all are true and the words are real then end game
func EvaluatePuzzle():
	ShowWordWarning(false)
	
	for HintTitle in Thing:
		if HintTitle[-1] == "D":
			SetColumnInvalid(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH, false)
		elif HintTitle[-1] == "A":
			SetRowInvalid(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH, false)
	
	var bDone : bool = true
	
	for HintTitle in Thing:
		if HintTitle[-1] == "D":
			var Res = EvaluateColumn(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH)
			var bWordDone = Res[0]
			var bWordInWordList = Res[1]
			if bWordDone:
				if not bWordInWordList:
					ShowWordWarning(true)
					SetColumnInvalid(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH, true)
					bDone = false
			else:
				bDone = false
				
		elif HintTitle[-1] == "A":
			var Res = EvaluateRow(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH)
			var bWordDone = Res[0]
			var bWordInWordList = Res[1]
			if bWordDone:
				if not bWordInWordList:
					ShowWordWarning(true)
					SetRowInvalid(Thing[HintTitle].x + Thing[HintTitle].y * GRID_WIDTH, true)
					bDone = false
			else:
				bDone = false
	
	ShowWinMessage(bDone)
	return bDone

func GoToNextTile():
	var Tries = TILE_COUNT
	
	var NextTile = ActiveIndex
	if CurrentHighlight == Constants.Highlight.RowActive:
		NextTile += 1
		if NextTile >= TILE_COUNT:
			NextTile = 0
			SetRowState(Constants.Highlight.Inactive)
			CurrentHighlight = Constants.Highlight.ColumnActive
		while Tiles[NextTile].GetBlocked() or Tiles[NextTile].GetCharacter() != "":
			NextTile += 1
			if NextTile >= TILE_COUNT:
				NextTile = 0
				SetRowState(Constants.Highlight.Inactive)
				CurrentHighlight = Constants.Highlight.ColumnActive
			Tries -= 1
			if Tries <= 0:
				return
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		NextTile += GRID_WIDTH
		if NextTile == TILE_COUNT + GRID_WIDTH - 1:
			NextTile = 0
			SetColumnState(Constants.Highlight.Inactive)
			CurrentHighlight = Constants.Highlight.RowActive
		elif NextTile >= TILE_COUNT:
			NextTile -= (TILE_COUNT - 1)
		while Tiles[NextTile].GetBlocked() or Tiles[NextTile].GetCharacter() != "":
			NextTile += GRID_WIDTH
			if NextTile >= TILE_COUNT:
				NextTile -= (TILE_COUNT - 1)
			Tries -= 1
			if Tries <= 0:
				return
	SetActive(NextTile)

func GoToPreviousTile():
	var PrevTile = ActiveIndex
	
	if CurrentHighlight == Constants.Highlight.RowActive:
		PrevTile -= 1
		if PrevTile < 0:
			PrevTile = TILE_COUNT - 1
			SetRowState(Constants.Highlight.Inactive)
			CurrentHighlight = Constants.Highlight.ColumnActive
		while Tiles[PrevTile].GetBlocked():
			PrevTile -= 1
			if PrevTile <= 0:
				PrevTile = TILE_COUNT - 1
				SetRowState(Constants.Highlight.Inactive)
				CurrentHighlight = Constants.Highlight.ColumnActive
	elif CurrentHighlight == Constants.Highlight.ColumnActive:
		if PrevTile == 0:
			SetColumnState(Constants.Highlight.Inactive)
			CurrentHighlight = Constants.Highlight.RowActive
			PrevTile = TILE_COUNT - 1
		elif PrevTile / GRID_HEIGHT == 0:
			PrevTile += TILE_COUNT - GRID_WIDTH - 1
		else:
			PrevTile -= GRID_WIDTH
		while Tiles[PrevTile].GetBlocked():
			if PrevTile == 0:
				SetColumnState(Constants.Highlight.Inactive)
				CurrentHighlight = Constants.Highlight.RowActive
				PrevTile = TILE_COUNT - 1
			elif PrevTile / GRID_HEIGHT == 0:
				PrevTile += TILE_COUNT - GRID_WIDTH - 1
			else:
				PrevTile -= GRID_WIDTH
	SetActive(PrevTile)

func _input(event: InputEvent) -> void:
	if bFocused and event is InputEventKey and event.is_pressed() and !event.is_echo():
		var label = DisplayServer.keyboard_get_label_from_physical(event.physical_keycode)
		if label == 4194308:
			if Tiles[ActiveIndex].GetCharacter() != "":
				Tiles[ActiveIndex].SetCharacter("")
				EvaluatePuzzle()
				return
			GoToPreviousTile()
			Tiles[ActiveIndex].SetCharacter("")
			EvaluatePuzzle()
		if 65 <= label and label <= 90:
			Tiles[ActiveIndex].SetCharacter(OS.get_keycode_string(label))
			if not EvaluatePuzzle():
				GoToNextTile()
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		var Min = position
		var Max = position + $GridBackground.size
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


func _on_next_level_button_button_down() -> void:
	GameWon.emit()
