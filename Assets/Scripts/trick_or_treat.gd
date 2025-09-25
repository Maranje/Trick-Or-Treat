extends Node2D

@onready var hand: Sprite2D = $Hand
@onready var doorbell: Sprite2D = $Doorbell
@onready var ding: AudioStreamPlayer2D = $Ding

var candy: int = 0
var candy_corn: int = 0
var static_center_pos: int = 340

func _ready() -> void:
	var hand_tween = create_tween()
	var doorbell_tween = create_tween()
	hand_tween.set_ease(Tween.EASE_IN_OUT)
	hand_tween.set_trans(Tween.TRANS_BACK)
	doorbell_tween.set_ease(Tween.EASE_IN)
	doorbell_tween.tween_property(doorbell, "position", Vector2(0, -50), 0.3)
	hand_tween.tween_property(hand, "position", Vector2(-30, -100), 0.65)
	doorbell_tween.tween_callback(_doorbell_pressed)

func _process(_delta: float) -> void:
	global_position.y = static_center_pos

func _doorbell_pressed():
	ding.play()
	TimerUtils.create_one_shot_timer(self, 0.7, _remove_this_node)
	
func _remove_this_node():
	get_parent().ui.run_notificon(candy, candy_corn)
	queue_free()
