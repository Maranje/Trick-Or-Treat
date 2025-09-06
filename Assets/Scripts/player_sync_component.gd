extends MultiplayerSynchronizer

var movement: Vector2 = Vector2.ZERO
var jump: bool = false
var animation_select: String
var direction: String = "left"
var at_door: bool = false
var scrapping: bool = false
var chuck_anim: bool = false
var throwing: bool = false
var esc_pressed: bool = false
var throw_timer: Timer

@onready var tag: String = PlayerGlobals.user_name

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		_gather_input(delta)
		
func _gather_input(delta: float):
	if get_parent().has_node("Squabble"):
		_static_situation(animation_select)
		_scrap_routine(delta)
		return
	if get_parent().player_health == 0:
		_static_situation("ko")
		return
	if not get_parent().player_active:
		_static_situation("idle")
		return
	if get_parent().has_node("TrickOrTreat"):
		_static_situation("back")
		return
	if throwing: return
	movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_set_animation()
	_check_throw()
	_check_door()

func toggle_at_door():
	at_door = !at_door
	
func _check_door():
	if not at_door: return
	if get_parent().has_node("TrickOrTreat"): return
	if Input.is_action_just_pressed("ui_up"):
		get_parent().trick_or_treat()
	
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
		_set_throw(-1500, "chuck_left_1", "chuck_left_2")
	elif Input.is_action_just_pressed("shoot_right"):
		_set_throw(1500, "chuck_right_1", "chuck_right_2")

func _set_throw(impulse: int, animation1: String, animation2: String):
	var parent = get_parent()
	movement = Vector2.ZERO
	throwing = true
	PlayerGlobals.edit_candy_corn(-1)
	parent.shoot_candy_corn.rpc_id(1, impulse)
	parent.ui.update_candies()
	if chuck_anim:
		animation_select = animation1
		chuck_anim = false
	else:
		animation_select = animation2
		chuck_anim = true
	throw_timer = Timer.new()
	add_child(throw_timer)
	throw_timer.wait_time = 0.15
	throw_timer.one_shot = true
	throw_timer.timeout.connect(_toggle_throwing_false)
	throw_timer.start()

func _static_situation(Anim: String):
	movement = Vector2.ZERO
	animation_select = Anim

func _toggle_throwing_false():
	throwing = false

func _scrap_routine(delta: float):
	var parent = get_parent()
	if Input.is_action_just_pressed("ui_esc") or parent.player_health == 0:
		if scrapping: end_squabble()
		scrapping = false
		return
	if not scrapping: return
	if Input.is_action_just_pressed("shoot_left"):
		_send_punch("punch_left")
	elif Input.is_action_just_pressed("shoot_right"):
		_send_punch("punch_right")
	elif Input.is_action_just_pressed("shift_left"):
		_send_block("block_left")
	elif Input.is_action_just_pressed("shift_right"):
		_send_block("block_right")
	var parent_squabble = parent.get_node("Squabble")
	if parent_squabble.gas < 50: parent_squabble._increment_gas(delta)
	if parent_squabble.def < 50: parent_squabble._increment_def(delta)
	parent_squabble._update_stats_displays()
	scrapping = true

func _send_punch(animation: String):
	var squabble = get_parent().get_node("Squabble")
	if squabble.punching or squabble.gas < 10: return
	squabble.punching = true
	var opponent = squabble.opponent
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		opponent.get_node("Squabble").show_punch.rpc_id(opponent.input_multiplayer_authority, animation)
	squabble.pov_punch.rpc_id(get_parent().input_multiplayer_authority, animation)

func _send_block(animation: String):
	var squabble = get_parent().get_node("Squabble")
	if squabble.punching: return
	var opponent = squabble.opponent
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		opponent.get_node("Squabble").show_block.rpc_id(opponent.input_multiplayer_authority, animation)
		squabble.pov_block.rpc_id(get_parent().input_multiplayer_authority, animation)
	
func end_squabble():
	var squabble = get_parent().get_node("Squabble")
	var opponent = squabble.opponent
	squabble.break_squabble.rpc_id(get_parent().input_multiplayer_authority)
	squabble.break_squabble.rpc_id(opponent.input_multiplayer_authority)
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		opponent.get_node("Squabble").break_squabble.rpc_id(opponent.input_multiplayer_authority)
		opponent.get_node("Squabble").break_squabble.rpc_id(get_parent().input_multiplayer_authority)
