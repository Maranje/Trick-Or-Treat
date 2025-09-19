extends MultiplayerSynchronizer

var movement: Vector2 = Vector2.ZERO
var jump: bool = false
var animation_select: String
var direction: String = "left"
var at_door: bool = false
var chuck_anim: bool = false
var throwing: bool = false
var scrapping: bool = false
var throw_timer: Timer

@onready var tag: String = PlayerGlobals.user_name

func _process(delta: float) -> void:
	if is_multiplayer_authority():
		_gather_input(delta)

func _gather_input(delta: float):
	var parent = get_parent()
	if parent.has_node("Squabble"):
		_static_situation(animation_select)
		_scrap_routine(delta)
		return
	if parent.player_health == 0:
		_static_situation("ko")
		return
	if not parent.player_active:
		_static_situation("idle")
		return
	if parent.has_node("TrickOrTreat"):
		_static_situation("back")
		return
	if throwing: return
	movement = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	_set_animation()
	_check_throw()
	_check_door()

func toggle_at_door():
	at_door = !at_door
	
func _check_sfx():
	if movement.y > 0:
		get_parent().play_sfx()
	
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
		get_parent().jumps += 1
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
	PlayerGlobals.candy_corn -= 1
	parent.shoot_candy_corn.rpc_id(1, impulse)
	parent.ui.update_candies()
	parent.candy_corn_thrown += 1
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
	if not parent.has_node("Squabble"): return
	var opponent = parent.get_node("Squabble").opponent
	if Input.is_action_pressed("ui_run") or parent.player_health == 0 or opponent.player_health == 0:
		if scrapping: end_squabble()
		scrapping = false
		return
	if Input.is_action_just_pressed("shoot_left"):
		_send_punch("punch_left")
	elif Input.is_action_just_pressed("shoot_right"):
		_send_punch("punch_right")
	elif Input.is_action_just_pressed("shift_left"):
		_send_block("block_left")
	elif Input.is_action_just_pressed("shift_right"):
		_send_block("block_right")
	var parent_squabble = parent.get_node("Squabble")
	var stats_changed = false
	if parent_squabble.gas < 50: 
		parent_squabble._increment_gas(delta)
		stats_changed = true
	if parent_squabble.def < 50: 
		parent_squabble._increment_def(delta)
		stats_changed = true

	if stats_changed:
		if opponent and is_instance_valid(opponent) and opponent.has_node("PlayerSyncComponent"):
			opponent.get_node("PlayerSyncComponent").sync_stats.rpc_id(opponent.input_multiplayer_authority, parent_squabble.def, parent_squabble.gas)
	
	_update_stats_displays()
	scrapping = true
	
func _update_stats_displays():
	var parent = get_parent() as Player
	var parent_squabble = parent.get_node("Squabble")
	var opponent = parent_squabble.opponent
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		parent_squabble.pov_hp.scale.y = 25 * (float(parent.player_health) / 50.0)
		parent_squabble.pov_def.scale.y = 25 * (parent_squabble.def / 50.0)
		parent_squabble.pov_gas.scale.y = 25 * (parent_squabble.gas / 50.0)
		parent_squabble.opp_hp.scale.y = 15 * (float(opponent.player_health) / 50.0)
		parent_squabble.opp_def.scale.y = 15 * (parent_squabble.def_opp / 50.0)
		parent_squabble.opp_gas.scale.y = 15 * (parent_squabble.gas_opp / 50.0)

func _send_punch(animation: String):
	var squabble = get_parent().get_node("Squabble")
	if squabble.punching or squabble.gas < 10: return
	squabble.punching = true
	var opponent = squabble.opponent
	if opponent and is_instance_valid(opponent) and opponent.has_node("PlayerSyncComponent"):
		opponent.get_node("PlayerSyncComponent").show_punch.rpc_id(opponent.input_multiplayer_authority, animation)
	pov_punch.rpc_id(get_parent().input_multiplayer_authority, animation)

func _send_block(animation: String):
	var squabble = get_parent().get_node("Squabble")
	if squabble.punching: return
	var opponent = squabble.opponent
	if opponent and is_instance_valid(opponent) and opponent.has_node("PlayerSyncComponent"):
		opponent.get_node("PlayerSyncComponent").show_block.rpc_id(opponent.input_multiplayer_authority, animation)
		pov_block.rpc_id(get_parent().input_multiplayer_authority, animation)
	
func end_squabble():
	var squabble = get_parent().get_node("Squabble")
	var opponent = squabble.opponent
	break_squabble.rpc_id(get_parent().input_multiplayer_authority)
	break_squabble.rpc_id(opponent.input_multiplayer_authority)
	if opponent and is_instance_valid(opponent) and opponent.has_node("PlayerSyncComponent"):
		opponent.get_node("PlayerSyncComponent").break_squabble.rpc_id(opponent.input_multiplayer_authority)
		opponent.get_node("PlayerSyncComponent").break_squabble.rpc_id(get_parent().input_multiplayer_authority)

@rpc("any_peer", "call_local", "reliable")
func edit_candy(candy: int):
	if candy < 0 and PlayerGlobals.candy_count <= 0:
		return
	if get_parent().has_node("Squabble") and candy < 0:
		get_parent().get_node("Squabble").lose_candy()
		get_parent().candy_lost += 1
	elif get_parent().has_node("Squabble") and candy > 0:
		get_parent().get_node("Squabble").gain_candy()
		get_parent().candy_robbed += 1
	PlayerGlobals.candy_count += candy

@rpc("any_peer", "call_local", "reliable")
func play_pop_rpc(frame: int):
	if not get_parent().has_node("Squabble"): return
	var squabble = get_parent().get_node("Squabble")
	squabble.play_pop(frame)

@rpc("any_peer", "call_local", "reliable")
func sync_stats(new_def: float, new_gas: float):
	if not get_parent().has_node("Squabble"): return
	var squabble = get_parent().get_node("Squabble")
	squabble.def_opp = new_def
	squabble.gas_opp = new_gas

@rpc("any_peer", "call_local", "reliable")
func break_squabble():
	if get_parent().has_node("Squabble"):
		get_parent().ui.update_candies()
		get_parent().get_node("Squabble").queue_free()

@rpc("any_peer", "call_local", "reliable")
func pov_punch(animation: String):
	if not get_parent().has_node("Squabble"): return
	var squabble = get_parent().get_node("Squabble")
	squabble.decrememnt_gas()
	squabble.pov.animation = animation
	squabble.pov.play()
	if not squabble.punches.playing:
		squabble.punches.stream = squabble.punch_audio[randi() % 4]
		squabble.punches.play()
	var opponent = squabble.opponent
	if opponent and is_instance_valid(opponent) and opponent.has_node("PlayerSyncComponent"):
		opponent.get_node("PlayerSyncComponent").sync_stats.rpc_id(opponent.input_multiplayer_authority, squabble.def, squabble.gas)
	
@rpc("any_peer", "call_local", "reliable")
func pov_block(animation: String):
	if not get_parent().has_node("Squabble"): return
	var squabble = get_parent().get_node("Squabble")
	squabble.blocking_left = true
	squabble.pov.animation = animation
	squabble.pov.play()

@rpc("any_peer", "call_local", "reliable")
func show_punch(animation: String):
	if not get_parent().has_node("Squabble"): return
	var squabble = get_parent().get_node("Squabble")
	squabble.opp.animation = animation
	squabble.opp.play()
	if not squabble.opp.animation_finished.is_connected(_check_hit):
		squabble.opp.animation_finished.connect(func(): _check_hit(animation), CONNECT_ONE_SHOT)
	if not squabble.punches.playing:
		squabble.punches.stream = squabble.punch_audio[randi() % 4]
		squabble.punches.play()

@rpc("any_peer", "call_local", "reliable")
func show_block(animation: String):
	if not get_parent().has_node("Squabble"): return
	var squabble = get_parent().get_node("Squabble")
	squabble.opp.animation = animation
	squabble.opp.play()

@rpc("any_peer", "call_local", "reliable")
func report_dmg_dealt(dmg):
	get_parent().dmg_dealt += dmg

@rpc("any_peer", "call_local", "reliable")
func _check_hit(punch_direction: String):
	var parent = get_parent()
	if not get_parent().has_node("Squabble"): return
	var squabble = parent.get_node("Squabble")
	var opponent = squabble.opponent
	var calc_damage: float
	if not opponent or not \
		is_instance_valid(opponent) or not \
		opponent.has_node("PlayerSyncComponent") or not \
		opponent.has_node("Squabble"): return
	squabble._reset_square_up_opp()
	squabble.decrement_def(4)
	if (punch_direction == "punch_left" and squabble.blocking_right) or \
		(punch_direction == "punch_right" and squabble.blocking_left): 
			squabble.play_pop(1)
			opponent.get_node("PlayerSyncComponent").play_pop_rpc.rpc_id(opponent.input_multiplayer_authority, 0)
			calc_damage = 1 + (squabble.dmg_coefficient / squabble.def)
			parent.dmg_blocked += calc_damage
			return
	squabble.decrement_def(6)
	squabble.play_pop(2)
	
	if PlayerGlobals.candy_count > 0:
		edit_candy(-1)
		opponent.get_node("PlayerSyncComponent").play_pop_rpc.rpc_id(opponent.input_multiplayer_authority, 2)
		squabble.grunt.play()
		squabble.play_pop(2)
		opponent.get_node("PlayerSyncComponent").edit_candy.rpc_id(opponent.input_multiplayer_authority, 1)
		opponent.get_node("PlayerSyncComponent").play_pop_rpc.rpc_id(opponent.input_multiplayer_authority, 2)
	opponent.get_node("PlayerSyncComponent").sync_stats.rpc_id(opponent.input_multiplayer_authority, squabble.def, squabble.gas)
	calc_damage = 1 + (squabble.dmg_coefficient / squabble.def)
	parent.dmg_received += calc_damage
	opponent.get_node("PlayerSyncComponent").report_dmg_dealt.rpc_id(opponent.input_multiplayer_authority, calc_damage)
	parent.take_damage(calc_damage)
