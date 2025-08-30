extends Node2D

@onready var hand: Sprite2D = $Hand
@onready var doorbell: Sprite2D = $Doorbell
@onready var ding: AudioStreamPlayer2D = $Ding

func _ready() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(doorbell, "position", Vector2(0, -50), 0.5)
	tween.parallel().tween_property(hand, "position", Vector2(-30, -100), 0.65)
	tween.tween_callback(_doorbell_pressed)

func _doorbell_pressed():
	ding.play()
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.5
	timer.one_shot = true
	timer.timeout.connect(_remove_this_node)
	timer.start()
	
func _remove_this_node():
	queue_free()
