extends Area2D

var Owner
var Index
var CurrentState : Constants.TileState = Constants.TileState.Inactive

var IdleColor : Color = Color(1.0, 1.0, 1.0, 1.0)
var WordActiveColor : Color = Color(0.991, 1.0, 0.44, 1.0)
var TileActiveColor : Color = Color(0.451, 0.816, 1.0, 1.0)

func _ready() -> void:
	SetState(CurrentState)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		Owner.TileClicked(Index)

func SetCharacter(Character):
	$Label.text = Character

func GetCharacter():
	return $Label.text

func SetState(State : Constants.TileState):
	CurrentState = State
	if CurrentState == Constants.TileState.Inactive:
		$ColorRect.color = IdleColor
	elif CurrentState == Constants.TileState.WordActive:
		$ColorRect.color = WordActiveColor
	elif CurrentState == Constants.TileState.TileActive:
		$ColorRect.color = TileActiveColor
