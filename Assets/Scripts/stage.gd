extends Node

var player_scene: PackedScene = preload("uid://df8j72jtyei4v")
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var sky: Sprite2D = $Background/Sky
@onready var clouds: Node2D = $Background/Clouds
@onready var moon: Sprite2D = $Background/Moon
@onready var trees: Sprite2D = $Background/Trees
@onready var houses: Sprite2D = $Background/Houses
@onready var stage_theme: AudioStreamPlayer2D = $StageTheme
@onready var houses_body: Area2D = $Background/Houses/HouseBody

var ready_peers: Array[int] = []
var scene_ready_peers: Array[int] = []
var door_switch: bool = false

func _ready() -> void:
	# Set up the spawner
	player_spawner.spawn_function = func(data):
		var new_player = player_scene.instantiate() as Player
		new_player.position.x = (randi() % 177 + 2) * 40
		new_player.input_multiplayer_authority = data.peer_id
		new_player.name = str(data.peer_id)
		return new_player
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	scene_loaded.rpc_id(1)

func _process(_delta: float) -> void:
	# Get the local player (the one controlled by this client)
	var my_peer_id = multiplayer.get_unique_id()
	var my_player = get_node_or_null(str(my_peer_id))
	
	stage_theme.max_distance = INF
	
	if my_player and is_instance_valid(my_player):
		var player_pos = my_player.global_position
		sky.position.x = player_pos.x - 400
		moon.position.x = player_pos.x - 400
		if clouds:
			clouds.position.x = player_pos.x - 400
		trees.position.x = player_pos.x / 4.5
		houses.position.x = player_pos.x / 9

@rpc("any_peer", "call_local", "reliable")
func scene_loaded():
	if not multiplayer.is_server():
		return
	
	var sender_id = multiplayer.get_remote_sender_id()
	scene_ready_peers.append(sender_id)
	stage_ready_internal(sender_id)

func stage_ready_internal(peer_id: int):
	if peer_id in ready_peers:
		return
		
	ready_peers.append(peer_id)
	player_spawner.spawn({"peer_id": peer_id})

func _on_peer_disconnected(peer_id: int):
	
	if multiplayer.is_server():
		ready_peers.erase(peer_id)
		scene_ready_peers.erase(peer_id)
		
		var player_node = get_node_or_null(str(peer_id))
		if player_node and is_instance_valid(player_node):
			player_node.queue_free()

func _on_server_disconnected():
	ready_peers.clear()
	scene_ready_peers.clear()
	
	for child in get_children():
		if child is Player:
			child.queue_free()
