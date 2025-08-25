extends MultiplayerSynchronizer

var movement: Vector2 = Vector2.ZERO

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		_gather_input()
		
func _gather_input():
	movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
