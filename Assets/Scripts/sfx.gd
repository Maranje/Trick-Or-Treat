extends AudioStreamPlayer2D

func _ready() -> void:
	max_distance = INF
	play()
	finished.connect(_self_destruct)

func _self_destruct():
	print("?")
	queue_free()
