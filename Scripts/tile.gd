class_name Tile

extends Area2D

var Owner
var Index : int
var CurrentState : Constants.TileState = Constants.TileState.Inactive

var IdleColor : Color = Color(1.0, 1.0, 1.0, 1.0)
var WordActiveColor : Color = Color(0.991, 1.0, 0.44, 1.0)
var TileActiveColor : Color = Color(0.451, 0.816, 1.0, 1.0)
var TileBlockColor : Color = Color()

@onready var Letter : Label = $Letter
@onready var TileBackground : ColorRect = $TileBackground
@onready var WordNumber : Label = $WordNumber

func _ready() -> void:
	SetState(CurrentState)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		Owner.TileClicked(Index)

func SetWordNumber(Number : int):
	print(Number)
	WordNumber.text = str(Number)

func ClearWordNumber():
	WordNumber.text = ""

func SetCharacter(Character):
	Letter.text = Character

func GetCharacter():
	return Letter.text

func SetState(State : Constants.TileState):
	CurrentState = State
	if CurrentState == Constants.TileState.Inactive:
		TileBackground.color = IdleColor
	elif CurrentState == Constants.TileState.WordActive:
		TileBackground.color = WordActiveColor
	elif CurrentState == Constants.TileState.TileActive:
		TileBackground.color = TileActiveColor

func GetState():
	return CurrentState
