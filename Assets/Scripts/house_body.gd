extends Area2D

var player_at_door: bool = false

func _ready() -> void:
	body_entered.connect(_player_entered)
	body_exited.connect(_player_exited)
	
func _player_entered(body):
	body.player_sync_component.toggle_at_door()
	
func _player_exited(body):
	body.player_sync_component.toggle_at_door()
