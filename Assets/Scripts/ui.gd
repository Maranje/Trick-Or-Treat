extends Node2D

@onready var green_bar: Sprite2D = $GreenBar
@onready var red_bar: Sprite2D = $RedBar
@onready var top_right: Node2D = $TopRight
@onready var candy_label: Label = $TopRight/Candy/Label
@onready var candy_corn_label: Label = $TopRight/CandyCorn/Label
@onready var notificon: Node2D = $Notificon
@onready var candy_icon: Sprite2D = $Notificon/CandyIcon
@onready var candy_corn_icon: Sprite2D = $Notificon/CandyCornIcon

var static_center_pos: int = 272

func _ready() -> void:
	update_candies()
	candy_icon.modulate.a = 0
	candy_corn_icon.modulate.a = 0

func _process(_delta: float) -> void:
	top_right.global_position.y = static_center_pos

func update_candies():
	candy_label.text = str(PlayerGlobals.candy_count)
	candy_corn_label.text = str(PlayerGlobals.candy_corn)

func run_notificon(candy: bool, candy_corn: bool):
	
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(notificon, "position", Vector2(0, -25), 1)
	if candy: 
		tween.parallel().tween_property(candy_icon, "modulate:a", 1.0, 1)
		candy_icon.visible = true
	if candy_corn: 
		tween.parallel().tween_property(candy_corn_icon, "modulate:a", 1.0, 1)
		candy_corn_icon.visible = true
	tween.tween_callback(_notificon_reset)
	
func _notificon_reset():
	candy_icon.modulate.a = 0
	candy_corn_icon.modulate.a = 0
	notificon.position.y = 0
	candy_icon.visible = false
	candy_corn_icon.visible = false
	update_candies()

func update_health(current_health: int, max_health: int = 50):
	green_bar.scale.x = 50 * (float(current_health) / float(max_health))
