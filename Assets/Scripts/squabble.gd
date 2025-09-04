extends Node2D

@onready var opp: AnimatedSprite2D = $Opp
@onready var pov: Sprite2D = $POV
@onready var y_pos = 240
@onready var start_bell: AudioStreamPlayer2D = $Audio/StartBell
@onready var end_bell: AudioStreamPlayer2D = $Audio/EndBell
@onready var grunt: AudioStreamPlayer2D = $Audio/Grunt
@onready var punches: AudioStreamPlayer2D = $Audio/Punches

var opponent: Player
var printed: bool = false

func _ready():
	start_bell.play()
	var my_player = get_parent() as Player
	var my_peer_id = multiplayer.get_unique_id()
	if my_peer_id != my_player.input_multiplayer_authority:
		visible = false
	else:
		visible = true
	_reset_square_up()
	global_position.x = get_parent().position.x
	global_position.y = y_pos
	z_index = 1
	opp.animation_finished.connect(_reset_square_up)

func _reset_square_up():
	opp.animation = "square_up"
	opp.play()
