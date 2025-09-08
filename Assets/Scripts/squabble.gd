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
@onready var start_bell: AudioStreamPlayer2D = $Audio/StartBell
@onready var end_bell: AudioStreamPlayer2D = $Audio/EndBell
@onready var grunt: AudioStreamPlayer2D = $Audio/Grunt
@onready var punches: AudioStreamPlayer2D = $Audio/Punches
@onready var pops: Sprite2D = $UI/Pops
@onready var candy_ui: Sprite2D = $UI/CandyUI
@onready var y_pos = 240
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
	_reset_candy_ui()
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
	
func _increment_def(delta: float):
	def += 3 * delta
	if def > 50: def = 50

func decrememnt_gas():
	gas -= 10
	if gas < 0: gas = 0
	
func decrement_def(amount: int):
	def -= amount
	if def < 1: def = 1
	
func gain_candy():
	candy_ui.position.x = 100
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(candy_ui, "position:x", -216, 0.5)
	tween.parallel().tween_property(candy_ui, "modulate:g", 255, 0.5)
	tween.tween_callback(_reset_candy_ui)
	candy_ui.visible = true

func lose_candy():
	candy_ui.position.x = -216
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(candy_ui, "position:x", 100, 0.5)
	tween.parallel().tween_property(candy_ui, "modulate:r", 255, 0.5)
	tween.tween_callback(_reset_candy_ui)
	candy_ui.visible = true

func _reset_candy_ui():
	candy_ui.visible = false
	candy_ui.modulate.r = 0
	candy_ui.modulate.g = 0
	candy_ui.modulate.b = 0

func _reset_square_up_opp():
	opp.animation = "square_up"
	opp.play()
	
func _reset_square_up_pov():
	pov.animation = "square_up"
	pov.play()
	punching = false

func play_pop(frame: int):
	pops.position.x = position.x + (randi() % 100 - 100)
	pops.position.y = position.y + (randi() % 100 - 100)
	pops.frame = frame
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.wait_time = 0.5
	timer.timeout.connect(_reset_pop)
	timer.start()
	
func _reset_pop():
	pops.frame = 3

func _on_peer_disconnected(peer_id: int):
	if opponent and opponent.input_multiplayer_authority == peer_id:
		print("Opponent disconnected during squabble, breaking squabble gracefully")
		var parent = get_parent() as Player
		if parent.has_node("PlayerSyncComponent"):
			parent.get_node("PlayerSyncComponent").break_squabble.rpc_id(parent.input_multiplayer_authority)
