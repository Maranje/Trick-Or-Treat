extends MultiplayerSynchronizer

var movement: Vector2 = Vector2.ZERO
var jump: bool = false
var animation_select: String
var direction: String = "left"

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		_gather_input()
		
func _gather_input():
	movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if get_parent().velocity.y:
		jump = false
		if direction == "left":
			animation_select = "left_jump"
		elif direction == "right":
			animation_select = "right_jump"
	elif Input.is_action_just_pressed("ui_accept"):
		jump = true
		
	elif movement.x < 0: 
		animation_select = "left"
		direction = "left"
	elif movement.x > 0: 
		animation_select = "right"
		direction = "right"
	else: animation_select = "idle"
