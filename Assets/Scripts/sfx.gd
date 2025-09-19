extends Node2D
@onready var sfx: AudioStreamPlayer2D = $SFX
var stream: int = 0
var streams: Array = [
	null,
	load("uid://b45fg0kwyq6yb"),
	load("uid://dlphsy8ed7j5d"),
	load("uid://b2bjwqtqyj87n")
]

func _ready() -> void:
	sfx.stream = streams[stream]
	#sfx.max_distance = INF
	sfx.play()
	sfx.finished.connect(_self_destruct)

func _self_destruct():
	queue_free()
