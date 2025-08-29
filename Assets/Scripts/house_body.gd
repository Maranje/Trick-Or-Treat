extends Area2D

var player_at_door: bool = false
var collider_index: int

func _ready() -> void:
	body_shape_entered.connect(_player_entered)
	body_exited.connect(_player_exited)

func _player_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int):
	body.door_number = local_shape_index #get specific door trigger id
	body.player_sync_component.toggle_at_door()
	
func _player_exited(body):
	body.player_sync_component.toggle_at_door()
