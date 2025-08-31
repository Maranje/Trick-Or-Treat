extends MultiplayerSynchronizer

var movement: Vector2 = Vector2.ZERO
var jump: bool = false
var animation_select: String
var direction: String = "left"
var at_door: bool = false
var chuck_left: bool = false
var chuck_right: bool = false
var throwing: bool = false
var throw_timer: Timer

@onready var tag: String = PlayerGlobals.user_name

func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		_gather_input()
		
func _gather_input():
	if throwing: return
	if get_parent().has_node("TrickOrTreat"):
		movement = Vector2.ZERO
		animation_select = "back"
		return
	movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_set_animation()
	_check_throw()

func toggle_at_door():
	at_door = !at_door
	
func _set_animation():
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
	
func _check_throw():
	if PlayerGlobals.candy_corn <= 0: return 
	if Input.is_action_just_pressed("shoot_left"):
		get_parent().shoot_candy_corn.rpc_id(1, -1000)
		PlayerGlobals.remove_one_candy_corn()
		if chuck_left:
			animation_select = "chuck_left_1"
			chuck_left = false
		else:
			animation_select = "chuck_left_2"
			chuck_left = true
		_set_throw()
	elif Input.is_action_just_pressed("shoot_right"):
		get_parent().shoot_candy_corn.rpc_id(1, 1000)
		PlayerGlobals.remove_one_candy_corn()
		print(PlayerGlobals.candy_corn)
		if chuck_right:
			animation_select = "chuck_right_1"
			chuck_right = false
		else:
			animation_select = "chuck_right_2"
			chuck_right = true
		_set_throw()

func _set_throw():
	movement = Vector2.ZERO
	throwing = true
	throw_timer = Timer.new()
	add_child(throw_timer)
	throw_timer.wait_time = 0.15
	throw_timer.one_shot = true
	throw_timer.timeout.connect(_toggle_throwing_false)
	throw_timer.start()

func _toggle_throwing_false():
	throwing = false
