extends AudioStreamPlayer2D

func _ready() -> void:
	play()
	finished.connect(_self_destruct)

func _self_destruct():
	queue_free()
