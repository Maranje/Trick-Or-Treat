extends MultiplayerSynchronizer

var movement: Vector2 = Vector2.ZERO
var jump: bool = false
var animation_select: String
var direction: String = "left"
var at_door: bool = false

@onready var tag: String = PlayerGlobals.user_name

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		_gather_input()
		
func _gather_input():
	if get_parent().has_node("TrickOrTreat"):
		movement = Vector2.ZERO
		if at_door:
			animation_select = "back"
		else: animation_select = "idle"
		return
	
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
	elif at_door:
		animation_select = "back"
	else: animation_select = "idle"

func toggle_at_door():
	at_door = !at_door
	
