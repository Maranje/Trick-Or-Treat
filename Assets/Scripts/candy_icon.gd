extends Sprite2D

var frame_number: int

func _ready() -> void:
	var travel_time = (randi() % 150 + 50) / 100.0
	var destination: Vector2
	frame = frame_number
	if frame_number == 0:
		destination = Vector2(GameConstants.CANDY_ICON_DESTINATION_CANDY_X, GameConstants.CANDY_ICON_DESTINATION_Y)
	elif frame_number == 1:
		destination = Vector2(GameConstants.CANDY_ICON_DESTINATION_CORN_X, GameConstants.CANDY_ICON_DESTINATION_Y)
	modulate.a = 0
	var tween = TweenUtils.create_candy_icon_tween(self, destination, travel_time)
	tween.finished.connect(_remove_icon)
	
func _remove_icon():
	if frame_number == 0:
		PlayerGlobals.candy_count += 1
	elif frame_number == 1:
		PlayerGlobals.candy_corn += 1
	get_parent().get_parent().update_candies()
	queue_free()
