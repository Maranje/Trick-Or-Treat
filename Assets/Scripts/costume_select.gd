extends Node2D

@onready var costume: Sprite2D = $Costume
@onready var button_left: Button = $ButtonLeft
@onready var button_right: Button = $ButtonRight

var costume_number: int

func _ready() -> void:
	button_left.pressed.connect(_costume_button_left_pressed)
	button_right.pressed.connect(_costume_button_right_pressed)
	button_left.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button_right.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
func _costume_button_left_pressed():
	costume_number -= 1
	if costume_number < 0: costume_number = 35
	costume_number = costume_number % 36
	costume.frame = costume_number
	
func _costume_button_right_pressed():
	costume_number += 1
	costume_number = costume_number % 36
	costume.frame = costume_number
