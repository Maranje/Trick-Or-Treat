extends Node2D
@onready var sfx: AudioStreamPlayer2D = $SFX
var stream

func _ready() -> void:
	sfx.stream = stream
	sfx.max_distance = INF
	sfx.play()
	sfx.finished.connect(_self_destruct)

func _self_destruct():
	queue_free()
