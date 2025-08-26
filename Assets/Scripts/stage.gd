extends Node

var player_scene: PackedScene = preload("uid://df8j72jtyei4v")
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

func _ready() -> void:
	player_spawner.spawn_function = func(data):
		var new_player = player_scene.instantiate() as Player
		new_player.input_multiplayer_authority = data.peer_id
		new_player.name = str(data.peer_id)
		print("Created player for peer: ", data.peer_id)
		return new_player
	
	await get_tree().process_frame
	
	stage_ready.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func stage_ready():
	var sender_id = multiplayer.get_remote_sender_id()
	player_spawner.spawn({"peer_id": sender_id})
