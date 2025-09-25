extends Node2D

@onready var costume: Sprite2D = $Costume
@onready var button_left: Button = $ButtonLeft
@onready var button_right: Button = $ButtonRight
@onready var buy_button: Button = $BuyButton
@onready var costume_number: int = PlayerGlobals.current_costume

func _ready() -> void:
	costume.frame = costume_number
	button_left.pressed.connect(_costume_button_left_pressed)
	button_right.pressed.connect(_costume_button_right_pressed)
	button_left.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button_right.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	buy_button.pressed.connect(_buy_pressed)
	buy_button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	update_ui()

func update_ui():
	if costume_number in PlayerGlobals.costumes_owned:
		buy_button.visible = false
		get_tree().current_scene.get_node("Lobby/Ready").disabled = false
	else: 
		buy_button.visible = true
		get_tree().current_scene.get_node("Lobby/Ready").disabled = true
	
func _costume_button_left_pressed():
	costume_number -= 1
	if costume_number < 0: costume_number = PlayerGlobals.costumes.size() - 1
	costume.frame = costume_number
	PlayerGlobals.current_costume = costume_number
	update_ui()
	
func _costume_button_right_pressed():
	costume_number += 1
	costume_number = costume_number % PlayerGlobals.costumes.size()
	costume.frame = costume_number
	PlayerGlobals.current_costume = costume_number
	update_ui()

func _buy_pressed():
	if PlayerGlobals.candy_count >= GameConstants.COSTUME_COST:
		PlayerGlobals.costumes_owned.append(int(costume_number))
		PlayerGlobals.candy_count -= GameConstants.COSTUME_COST
		PlayerGlobals.save_data()
		update_ui()
		get_parent().get_node("CandyCounter").update()
	else:
		get_tree().current_scene.update_error_label("Not enough candy")
