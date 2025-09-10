extends Node

var disconnect_scene: PackedScene = preload("uid://ctmuv3sgstkfa")
var player_scene: PackedScene = preload("uid://df8j72jtyei4v")
var loot: PackedScene = preload("uid://cn7qqf8r4561v")
var splash_scene: PackedScene
@onready var loot_spawner: MultiplayerSpawner = $LootSpawner
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var bg: Node2D = $Background
@onready var sky: Sprite2D = $Background/Sky
@onready var clouds: Node2D = $Background/Clouds
@onready var moon: Sprite2D = $Background/Moon
@onready var trees: Sprite2D = $Background/Trees
@onready var houses: Sprite2D = $Background/Houses
@onready var houses_body: Area2D = $Background/Houses/HouseBody
@onready var theme: AudioStreamPlayer2D = $Audio/StageTheme
@onready var wind_down: AudioStreamPlayer2D = $Audio/WindDownTheme
@onready var buzzer:AudioStreamPlayer2D = $Audio/BuzzerTheme
@onready var tally: AudioStreamPlayer2D = $Audio/TallyTheme
@onready var blast: AudioStreamPlayer2D = $Audio/BlastTheme
@onready var end: AudioStreamPlayer2D = $Audio/EndTheme
@onready var curtains_1: Sprite2D = $Curtains1
@onready var curtains_2: Sprite2D = $Curtains2
@onready var title_card: Node2D = $TitleCard
@onready var stats: Node2D = $Stats
@onready var candy_gathered: Label = $Stats/CandyGathered
@onready var candy_robbed: Label = $Stats/CandyRobbed
@onready var candy_lost: Label = $Stats/CandyLost
@onready var candy_corn_gathered: Label = $Stats/CandyCornGathered
@onready var candy_corn_thrown: Label = $Stats/CandyCornThrown
@onready var houses_hit: Label = $Stats/HousesHit
@onready var houses_revisited: Label = $Stats/HousesRevisited
@onready var jumps: Label = $Stats/Jumps
@onready var dmg_dealt: Label = $Stats/DMGDealt
@onready var dmg_received: Label = $Stats/DMGReceived
@onready var dmg_blocked: Label = $Stats/DMGBlocked

var players: Dictionary = {}
var stage_ended: bool = false
var static_center_pos: int = 180

func _ready() -> void:
	theme.max_distance = INF
	buzzer.max_distance = INF
	wind_down.max_distance = INF
	tally.max_distance = INF
	blast.max_distance = INF
	end.max_distance = INF
	
	player_spawner.spawn_function = func(data):
		var new_player = player_scene.instantiate() as Player
		new_player.position.x = _find_safe_spawn_position()
		new_player.input_multiplayer_authority = data.peer_id
		new_player.name = str(data.peer_id)
		if data.has("costume"):
			new_player.sprite_frames = data.costume
		if data.has("user_name"):
			new_player.user_name = data.user_name
		players[new_player.name] = new_player
		return new_player
		
	loot_spawner.spawn_function = func(data):
		var new_loot = loot.instantiate()
		new_loot.position = data.position
		new_loot.rix = data.rix
		new_loot.riy = data.riy
		new_loot.frame = data.frame
		return new_loot
	
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.server_disconnected.connect(_on_server_disconnected)
	theme.finished.connect(_stage_play_finished)
	buzzer.finished.connect(_level_fade)
	wind_down.finished.connect(_start_tally)
	tally.finished.connect(_blast)
	blast.finished.connect(_end_run)
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.timeout.connect(_load_stage)
	timer.start()

func _load_stage():
	scene_loaded.rpc_id(1, PlayerGlobals.current_costume, PlayerGlobals.user_name)

func _process(_delta: float) -> void:
	var my_peer_id = multiplayer.get_unique_id()
	var my_player = get_node_or_null(str(my_peer_id))
	if my_player and is_instance_valid(my_player):
		if my_player.player_health < 50: print("!")
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
	
	if players.has(str(peer_id)):
		return
		
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
	if not splash_scene:
		splash_scene = load("uid://cvr7jcnvq23fm")
	if splash_scene:
		get_tree().change_scene_to_packed(splash_scene)
	else:
		print("Error: Failed to load splash scene")

func _stage_play_finished():
	buzzer.play()
	var my_peer_id = multiplayer.get_unique_id()
	var my_player = get_node_or_null(str(my_peer_id))
	my_player.player_active = false

func _level_fade():
	wind_down.play()
	var my_peer_id = multiplayer.get_unique_id()
	var my_player = get_node_or_null(str(my_peer_id))
	if my_player and is_instance_valid(my_player):
		var player_pos = my_player.global_position
		curtains_1.modulate.a = 0.0
		curtains_1.visible = true
		curtains_1.position.x = player_pos.x - 400
	var tween = create_tween()
	tween.tween_property(curtains_1, "modulate:a", 1.0, 6.27)

func _start_tally():
	var player =  players[str(multiplayer.get_unique_id())]
	var tween = create_tween()
	stats.global_position.y = static_center_pos
	candy_gathered.text = str("candy gathered: ", player.candy_gathered)
	candy_robbed.text = str("candy robbed: ", player.candy_robbed)
	candy_lost.text = str("candy lost: ", player.candy_lost)
	candy_corn_gathered.text = str("candy corn gathered: ", player.candy_corn_gathered)
	candy_corn_thrown.text = str("candy corn thrown: ", player.candy_corn_thrown)
	houses_hit.text = str("houses hit: ", player.houses_hit)
	houses_revisited.text = str("houses revisited: ", player.houses_revisited)
	jumps.text = str("jumps: ", player.jumps)
	dmg_dealt.text = str("damage dealt: ", "%.4f" % player.dmg_dealt)
	dmg_received.text = str("damage received: ", "%.4f" % player.dmg_received)
	dmg_blocked.text = str("damage blocked: ", "%.4f" % player.dmg_blocked)
	tween.tween_property(candy_gathered, "position", Vector2(player.position.x - 300, stats.position.y - 250), 1)
	tween.parallel().tween_property(candy_robbed, "position", Vector2(player.position.x - 300, stats.position.y - 230), 1.5)
	tween.parallel().tween_property(candy_lost, "position", Vector2(player.position.x - 300, stats.position.y - 210), 2)
	tween.parallel().tween_property(candy_corn_gathered, "position", Vector2(player.position.x - 300, stats.position.y - 190), 2.5)
	tween.parallel().tween_property(candy_corn_thrown, "position", Vector2(player.position.x - 300, stats.position.y - 170), 3)
	tween.parallel().tween_property(houses_hit, "position", Vector2(player.position.x - 300, stats.position.y - 150), 3.5)
	tween.parallel().tween_property(houses_revisited, "position", Vector2(player.position.x - 300, stats.position.y - 130), 4)
	tween.parallel().tween_property(jumps, "position", Vector2(player.position.x - 300, stats.position.y - 110), 4.5)
	tween.parallel().tween_property(dmg_dealt, "position", Vector2(player.position.x - 300, stats.position.y - 90), 5)
	tween.parallel().tween_property(dmg_received, "position", Vector2(player.position.x - 300, stats.position.y - 70), 5.5)
	tween.parallel().tween_property(dmg_blocked, "position", Vector2(player.position.x - 300, stats.position.y - 50), 6)
	tally.play()

func _blast():
	blast.play()
	var my_peer_id = multiplayer.get_unique_id()
	var my_player = get_node_or_null(str(my_peer_id))
	if my_player and is_instance_valid(my_player):
		var player_pos = my_player.global_position
		title_card.position.x = player_pos.x - 400
		title_card.z_index = 1
		title_card.visible = true

func _end_run():
	if multiplayer.is_server():
		_change_scene.rpc()

@rpc("authority", "call_local", "reliable")
func _find_safe_spawn_position() -> float:
	var min_distance = 200
	var max_attempts = 50
	var map_width = 177 * 40

	for attempt in max_attempts:
		var spawn_x = (randi() % 177 + 2) * 40
		var safe_position = true

		for player in players.values():
			if is_instance_valid(player):
				var distance = abs(spawn_x - player.position.x)
				if distance < min_distance:
					safe_position = false
					break

		if safe_position:
			return spawn_x

	var player_count = players.size()
	return (player_count * 300) % map_width + 80

@rpc("authority", "call_local", "reliable")
func _change_scene():
	if multiplayer.is_server():
		for player in players.values():
			if is_instance_valid(player):
				player.queue_free()
		players.clear()

	multiplayer.multiplayer_peer = null
	
	if not splash_scene:
		splash_scene = load("uid://cvr7jcnvq23fm")
	if splash_scene:
		get_tree().change_scene_to_packed(splash_scene)
	else:
		print("Error: Failed to load splash scene")
