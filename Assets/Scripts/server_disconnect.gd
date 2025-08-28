extends Node

var splash_scene: PackedScene

func _ready() -> void:
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1
	timer.one_shot = true
	timer.timeout.connect(_on_timeout)
	timer.start()

func _on_timeout():
	splash_scene = load("uid://cvr7jcnvq23fm")
	get_tree().change_scene_to_packed(splash_scene)
