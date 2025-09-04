extends Node

@onready var scrap_window: Node2D = $ScrapWindow
@onready var opp: AnimatedSprite2D = $ScrapWindow/Opp
@onready var pov: Sprite2D = $ScrapWindow/POV
@onready var y_pos = 240
var opponent: Player
var printed: bool = false

func _ready():
	_reset_square_up()
	scrap_window.position.x = get_parent().position.x
	scrap_window.position.y = y_pos
	scrap_window.z_index = 1
	opp.animation_finished.connect(_reset_square_up)

func _process(_delta: float) -> void:
	if not printed:
		print("squaring up with: ", opponent.user_name)
		printed = true

func _reset_square_up():
	opp.animation = "square_up"
	opp.play()
