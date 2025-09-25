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
var gas: float
var def: float
@onready var gas_opp: float = GameConstants.MAX_GAS
@onready var def_opp: float = GameConstants.MAX_DEFENSE
@onready var dmg_coefficient = GameConstants.SQUABBLE_DMG_COEFFICIENT
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
	var my_player = get_parent() as Player
	def = my_player.player_defense
	gas = my_player.player_gas
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
	start_bell.play()
	ui.play()

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
	gas += GameConstants.SQUABBLE_GAS_INCREMENT_RATE * delta
	if gas > GameConstants.MAX_GAS: gas = GameConstants.MAX_GAS
	var my_player = get_parent() as Player
	my_player.player_gas = gas
	
func _increment_def(delta: float):
	def += GameConstants.SQUABBLE_DEF_INCREMENT_RATE * delta
	if def > GameConstants.MAX_DEFENSE: def = GameConstants.MAX_DEFENSE
	var my_player = get_parent() as Player
	my_player.player_defense = def

func decrement_gas():
	gas -= GameConstants.SQUABBLE_GAS_DECREMENT_PUNCH
	if gas < 0: gas = 0
	var my_player = get_parent() as Player
	my_player.player_gas = gas
	
func decrement_def(amount: int):
	def -= amount
	if def < GameConstants.SQUABBLE_MIN_DEF_VALUE: def = GameConstants.SQUABBLE_MIN_DEF_VALUE
	var my_player = get_parent() as Player
	my_player.player_defense = def
	
func gain_candy():
	var tween = TweenUtils.create_candy_ui_tween(candy_ui, 100, -216, "g")
	tween.tween_callback(_reset_candy_ui)
	candy_ui.visible = true

func lose_candy():
	var tween = TweenUtils.create_candy_ui_tween(candy_ui, -216, 100, "r")
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
	TimerUtils.create_one_shot_timer(self, 0.5, _reset_pop)
	
func _reset_pop():
	pops.frame = 3

func _on_peer_disconnected(peer_id: int):
	if opponent and opponent.input_multiplayer_authority == peer_id:
		var parent = get_parent() as Player
		if parent.has_node("PlayerSyncComponent"):
			parent.get_node("PlayerSyncComponent").break_squabble.rpc_id(parent.input_multiplayer_authority)
