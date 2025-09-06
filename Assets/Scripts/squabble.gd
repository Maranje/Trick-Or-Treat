extends Node2D

@onready var opp: AnimatedSprite2D = $Opp
@onready var pov: AnimatedSprite2D = $POV
@onready var ui: AnimatedSprite2D = $UI/Instructions
@onready var opp_hp: Sprite2D = $UI/OppStats/HP
@onready var opp_def: Sprite2D = $UI/OppStats/DEF
@onready var opp_gas: Sprite2D = $UI/OppStats/GAS
@onready var pov_hp: Sprite2D = $UI/POVStats/HP
@onready var pov_def: Sprite2D = $UI/POVStats/DEF
@onready var pov_gas: Sprite2D = $UI/POVStats/GAS
@onready var y_pos = 240
@onready var start_bell: AudioStreamPlayer2D = $Audio/StartBell
@onready var end_bell: AudioStreamPlayer2D = $Audio/EndBell
@onready var grunt: AudioStreamPlayer2D = $Audio/Grunt
@onready var punches: AudioStreamPlayer2D = $Audio/Punches
@onready var gas: float = 50
@onready var def: float = 50
@onready var gas_opp: float = 50
@onready var def_opp: float = 50
@onready var dmg_coefficient = 10
@onready var punch_audio = [
	preload("uid://dtyqjjnfxvue0"),
	preload("uid://gdsvuhydau47"),
	preload("uid://bdwu8u0buoq0r"),
	preload("uid://dcfl75nd333c3")
]
var opponent: Player
var blocking_left: bool = false
var blocking_right: bool = false
var punching: bool = false

func _ready():
	start_bell.play()
	ui.play()
	var my_player = get_parent() as Player
	var my_peer_id = multiplayer.get_unique_id()
	if my_peer_id != my_player.input_multiplayer_authority:
		visible = false
	else:
		visible = true
	_reset_square_up_opp()
	_reset_square_up_pov()
	global_position.x = get_parent().position.x
	global_position.y = y_pos
	z_index = 1
	pov.animation_finished.connect(_reset_square_up_pov)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func _process(_delta: float) -> void:
	if multiplayer.get_unique_id() != get_parent().input_multiplayer_authority: return
	global_position.y = y_pos
	if pov.animation == "block_left":
		blocking_left = true
		blocking_right = false
	elif pov.animation == "block_right":
		blocking_right = true
		blocking_left = false
	else:
		blocking_left = false
		blocking_right = false
	
func _increment_gas(delta: float):
	gas += 5 * delta
	if gas > 50: gas = 50
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		var opp_squabble = opponent.get_node("Squabble")
		if is_instance_valid(opp_squabble):
			opp_squabble.sync_stats.rpc_id(opponent.input_multiplayer_authority, def, gas)
	
func _increment_def(delta: float):
	def += 3 * delta
	if def > 50: def = 50
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		var opp_squabble = opponent.get_node("Squabble")
		if is_instance_valid(opp_squabble):
			opp_squabble.sync_stats.rpc_id(opponent.input_multiplayer_authority, def, gas)

func decrememnt_gas():
	gas -= 10
	if gas < 0: gas = 0
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		var opp_squabble = opponent.get_node("Squabble")
		if is_instance_valid(opp_squabble):
			opp_squabble.sync_stats.rpc_id(opponent.input_multiplayer_authority, def, gas)
	
func decrement_def(amount: int):
	def -= amount
	if def < 1: def = 1
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		var opp_squabble = opponent.get_node("Squabble")
		if is_instance_valid(opp_squabble):
			opp_squabble.sync_stats.rpc_id(opponent.input_multiplayer_authority, def, gas)

func _reset_square_up_opp():
	opp.animation = "square_up"
	opp.play()
	
func _reset_square_up_pov():
	pov.animation = "square_up"
	pov.play()
	punching = false
	
@rpc("any_peer", "call_local", "reliable")
func sync_stats(new_def: float, new_gas: float):
	def_opp = new_def
	gas_opp = new_gas

@rpc("any_peer", "call_local", "reliable")
func break_squabble():
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func pov_punch(animation: String):
	decrememnt_gas()
	pov.animation = animation
	pov.play()
	if not punches.playing:
		punches.stream = punch_audio[randi() % 4]
		punches.play()
	
@rpc("any_peer", "call_local", "reliable")
func pov_block(animation: String):
	blocking_left = true
	pov.animation = animation
	pov.play()

@rpc("any_peer", "call_local", "reliable")
func show_punch(animation: String):
	opp.animation = animation
	opp.play()
	if not opp.animation_finished.is_connected(_check_hit):
		opp.animation_finished.connect(func(): _check_hit(animation), CONNECT_ONE_SHOT)
	if not punches.playing:
		punches.stream = punch_audio[randi() % 4]
		punches.play()

@rpc("any_peer", "call_local", "reliable")
func show_block(animation: String):
	opp.animation = animation
	opp.play()

func _update_stats_displays():
	var my_player = get_parent() as Player
	if opponent and is_instance_valid(opponent) and opponent.has_node("Squabble"):
		pov_hp.scale.y = 25 * (float(my_player.player_health) / 50.0)
		pov_def.scale.y = 25 * (def / 50.0)
		pov_gas.scale.y = 25 * (gas / 50.0)
		opp_hp.scale.y = 15 * (float(opponent.player_health) / 50.0)
		opp_def.scale.y = 15 * (def_opp / 50.0)
		opp_gas.scale.y = 15 * (gas_opp / 50.0)

@rpc("any_peer", "call_local", "reliable")
func _check_hit(punch_direction: String):
	_reset_square_up_opp()
	decrement_def(4)
	if (punch_direction == "punch_left" and blocking_right) or \
	(punch_direction == "punch_right" and blocking_left): return
	decrement_def(6)
	var parent = get_parent()
	var calc_damage = 1 + (dmg_coefficient / def)
	parent.take_damage(calc_damage)
	grunt.play()

func _on_peer_disconnected(peer_id: int):
	if opponent and opponent.input_multiplayer_authority == peer_id:
		print("Opponent disconnected during squabble, breaking squabble gracefully")
		break_squabble.rpc_id(get_parent().input_multiplayer_authority)
