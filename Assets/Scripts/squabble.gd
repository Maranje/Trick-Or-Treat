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
@onready var punch_audio = [
	preload("uid://dtyqjjnfxvue0"),
	preload("uid://gdsvuhydau47"),
	preload("uid://bdwu8u0buoq0r"),
	preload("uid://dcfl75nd333c3")
]

var opponent: Player
var blocking_left: bool = false
var blocking_right: bool = false

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
	_update_health_displays()

func _process(_delta: float) -> void:
	global_position.y = y_pos
	if pov.animation == "block_left":
		blocking_left = true
	elif pov.animation == "block_right":
		blocking_right = true
	else:
		blocking_left = false
		blocking_right = false

func _reset_square_up_opp():
	opp.animation = "square_up"
	opp.play()
	
func _reset_square_up_pov():
	pov.animation = "square_up"
	pov.play()
	
@rpc("any_peer", "call_local", "reliable")
func break_squabble():
	var my_player = get_parent()
	my_player.reset_squabbling_flag.rpc()
	if opponent and is_instance_valid(opponent):
		opponent.reset_squabbling_flag.rpc()
	queue_free()

@rpc("any_peer", "call_local", "reliable")
func pov_punch(animation: String):
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

func _update_health_displays():
	var my_player = get_parent() as Player
	if opponent and is_instance_valid(opponent):
		pov_hp.scale.y = 25 * (float(my_player.player_health) / 50.0)
		opp_hp.scale.y = 15 * (float(opponent.player_health) / 50.0)

@rpc("any_peer", "call_local", "reliable") 
func update_squabble_health():
	_update_health_displays()

@rpc("any_peer", "call_local", "reliable")
func _check_hit(punch_direction: String):
	_reset_square_up_opp()
	if (punch_direction == "punch_left" and blocking_right) or (punch_direction == "punch_right" and blocking_left):
		return
	
	var parent = get_parent()
	parent.take_damage(10)
	call_deferred("_update_health_displays")
	if opponent and opponent.has_node("Squabble"):
		opponent.get_node("Squabble").update_squabble_health.rpc()
	grunt.play()
