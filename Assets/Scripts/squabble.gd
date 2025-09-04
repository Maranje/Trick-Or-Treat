extends Node2D

@onready var opp: AnimatedSprite2D = $Opp
@onready var pov: Sprite2D = $POV
@onready var y_pos = 240
var opponent: Player
var printed: bool = false

func _ready():
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
