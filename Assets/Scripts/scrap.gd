extends Node

@onready var scrap_window: Node2D = $ScrapWindow
@onready var opp: AnimatedSprite2D = $ScrapWindow/Opp
@onready var pov: Sprite2D = $ScrapWindow/POV

func _ready() -> void:
	_reset_square_up()
	opp.animation_finished.connect(_reset_square_up)
		
func _reset_square_up():
	opp.animation = "square_up"
	opp.play()
