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
	notificon.global_position.y = static_center_pos

func update_candies():
	candy_label.text = str(PlayerGlobals.candy_count)
	candy_corn_label.text = str(PlayerGlobals.candy_corn)

func run_notificon(candy: bool, candy_corn: bool):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	if candy: 
		tween.tween_property(candy_icon, "position", Vector2(180, -125), 1)
		tween.parallel().tween_property(candy_icon, "modulate:a", 1.0, 0.5)
		tween.parallel().tween_property(candy_icon, "scale", Vector2(0.5, 0.5), 0.5)
		candy_icon.visible = true
	if candy_corn: 
		tween.parallel().tween_property(candy_corn_icon, "position", Vector2(151, -125), 1)
		tween.parallel().tween_property(candy_corn_icon, "modulate:a", 1.0, 0.5)
		tween.parallel().tween_property(candy_corn_icon, "scale", Vector2(0.5, 0.5), 0.5)
		candy_corn_icon.visible = true
	tween.tween_callback(_notificon_reset)
	
func _notificon_reset():
	candy_icon.modulate.a = 0
	candy_corn_icon.modulate.a = 0
	candy_icon.position = Vector2.ZERO
	candy_corn_icon.position = Vector2.ZERO
	candy_icon.visible = false
	candy_corn_icon.visible = false
	update_candies()

func update_health(current_health: int, max_health: int = 50):
	green_bar.scale.x = 20 * (float(current_health) / float(max_health))
