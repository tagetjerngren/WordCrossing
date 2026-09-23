class_name Tile

extends Area2D

var Owner
var Index : int
var CurrentState : Constants.TileState = Constants.TileState.Inactive

var IdleColor : Color = Color(1.0, 1.0, 1.0, 1.0)
var WordActiveColor : Color = Color(0.991, 1.0, 0.44, 1.0)
var TileActiveColor : Color = Color(0.451, 0.816, 1.0, 1.0)
var TileBlockColor : Color = Color()
var TileHintColor : Color = Color(1.0, 0.81, 0.62, 1.0)
#var InvalidWordColor : Color = Color(1.0, 0.19, 0.19, 1.0)

var bBlocked : bool = false
var bInvalidWord : bool = false

@onready var Letter : Label = $Letter
@onready var TileBackground : ColorRect = $TileBackground
@onready var WordNumber : Label = $WordNumber

func _ready() -> void:
	SetState(CurrentState)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT and not bBlocked:
		Owner.TileClicked(Index)


func SetWordNumber(Number : int):
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
	elif CurrentState == Constants.TileState.HintActive:
		TileBackground.color = TileHintColor

func GetState():
	return CurrentState

func GetBlocked():
	return bBlocked

func SetBlocked(Blocked : bool):
	bBlocked = Blocked

func SetInvalidWord(Invalid : bool):
	bInvalidWord = Invalid
	if Invalid:
		$InvalidWordWarning.show()
	else:
		$InvalidWordWarning.hide()
		#TileBackground.color = InvalidWordColor
