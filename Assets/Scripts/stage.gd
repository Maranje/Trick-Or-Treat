extends Node

var disconnect_scene: PackedScene = preload("uid://ctmuv3sgstkfa")
var player_scene: PackedScene = preload("uid://df8j72jtyei4v")

@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var sky: Sprite2D = $Background/Sky
@onready var clouds: Node2D = $Background/Clouds
@onready var moon: Sprite2D = $Background/Moon
@onready var trees: Sprite2D = $Background/Trees
@onready var houses: Sprite2D = $Background/Houses
@onready var stage_theme: AudioStreamPlayer2D = $StageTheme
@onready var houses_body: Area2D = $Background/Houses/HouseBody

var door_switch: bool = false

func _ready() -> void:
	stage_theme.max_distance = INF
	
	player_spawner.spawn_function = func(data):
		var new_player = player_scene.instantiate() as Player
		new_player.position.x = (randi() % 177 + 2) * 40
		new_player.input_multiplayer_authority = data.peer_id
		new_player.name = str(data.peer_id)
		# Pass costume data during spawn
		if data.has("costume"):
			new_player.sprite_frames = data.costume
		if data.has("user_name"):
			new_player.user_name = data.user_name
		return new_player
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	
	#stage load buffer timer
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.timeout.connect(_load_stage)
	timer.start()
	
func _load_stage():
	scene_loaded.rpc_id(1, PlayerGlobals.current_costume, PlayerGlobals.user_name)

func _process(_delta: float) -> void:
	# Get the local player (the one controlled by this client)
	var my_peer_id = multiplayer.get_unique_id()
	var my_player = get_node_or_null(str(my_peer_id))
	
	if my_player and is_instance_valid(my_player):
		var player_pos = my_player.global_position
		sky.position.x = player_pos.x - 400
		moon.position.x = player_pos.x - 400
		if clouds:
			clouds.position.x = player_pos.x - 400
		trees.position.x = player_pos.x / 4.5
		houses.position.x = player_pos.x / 9

@rpc("any_peer", "call_local", "reliable")
func scene_loaded(costume_data: int = 0, user_name_data: String = ""):
	if not multiplayer.is_server():
		return
	
	var peer_id = multiplayer.get_remote_sender_id()
	player_spawner.spawn({"peer_id": peer_id, "costume": costume_data, "user_name": user_name_data})

func _on_peer_disconnected(peer_id: int):
	if multiplayer.is_server():
		var player_node = get_node_or_null(str(peer_id))
		if player_node and is_instance_valid(player_node):
			player_node.queue_free()

func _on_server_disconnected():
	for child in get_children():
		if child is Player:
			child.queue_free()
	get_tree().change_scene_to_packed(disconnect_scene)
	
