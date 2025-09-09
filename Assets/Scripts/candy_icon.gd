extends Sprite2D

var frame_number: int

func _ready() -> void:
	var tween = create_tween()
	var travel_time = (randi() % 150 + 50) / 100.0
	var destination: Vector2
	frame = frame_number
	if frame_number == 0:
		destination = Vector2(180, -125)
	elif frame_number == 1:
		destination = Vector2(151, -125)
	modulate.a = 0
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", destination, travel_time)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(0.5, 0.5), travel_time)
	tween.finished.connect(_remove_icon)
	
func _remove_icon():
	if frame_number == 0:
		PlayerGlobals.candy_count += 1
	elif frame_number == 1:
		PlayerGlobals.candy_corn += 1
	get_parent().get_parent().update_candies()
	queue_free()
