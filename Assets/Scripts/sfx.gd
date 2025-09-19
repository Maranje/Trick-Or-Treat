extends AudioStreamPlayer2D

func _ready() -> void:
	max_distance = INF
	play()
	finished.connect(queue_free)
