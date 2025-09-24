extends Node

var splash_scene: PackedScene

func _ready() -> void:
	TimerUtils.create_one_shot_timer(self, 1.0, _on_timeout)

func _on_timeout():
	splash_scene = load("uid://cvr7jcnvq23fm")
	get_tree().change_scene_to_packed(splash_scene)
