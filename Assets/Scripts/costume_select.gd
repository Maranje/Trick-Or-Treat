extends Node2D

@onready var costume: Sprite2D = $Costume
@onready var button_left: Button = $ButtonLeft
@onready var button_right: Button = $ButtonRight
@onready var costume_number: int = PlayerGlobals.current_costume

func _ready() -> void:
	costume.frame = costume_number
	button_left.pressed.connect(_costume_button_left_pressed)
	button_right.pressed.connect(_costume_button_right_pressed)
	button_left.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button_right.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	
func _costume_button_left_pressed():
	costume_number -= 1
	if costume_number < 0: costume_number = PlayerGlobals.costume_count - 1
	costume_number = costume_number % PlayerGlobals.costume_count
	costume.frame = costume_number
	PlayerGlobals.current_costume = costume_number
	
func _costume_button_right_pressed():
	costume_number += 1
	costume_number = costume_number % PlayerGlobals.costume_count
	costume.frame = costume_number
	PlayerGlobals.current_costume = costume_number
