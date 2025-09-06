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
	
func _increment_def(delta: float):
	def += 3 * delta
	if def > 50: def = 50

func decrememnt_gas():
	gas -= 10
	if gas < 0: gas = 0
	
func decrement_def(amount: int):
	def -= amount
	if def < 1: def = 1

func _reset_square_up_opp():
	opp.animation = "square_up"
	opp.play()
	
func _reset_square_up_pov():
	pov.animation = "square_up"
	pov.play()
	punching = false

func _on_peer_disconnected(peer_id: int):
	if opponent and opponent.input_multiplayer_authority == peer_id:
		print("Opponent disconnected during squabble, breaking squabble gracefully")
		var parent = get_parent() as Player
		if parent.has_node("PlayerSyncComponent"):
			parent.get_node("PlayerSyncComponent").break_squabble.rpc_id(parent.input_multiplayer_authority)
