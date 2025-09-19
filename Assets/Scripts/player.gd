class_name Player
extends CharacterBody2D

var doorbell: PackedScene = preload("uid://bx542d0joldxk")
var sfx_scene: PackedScene = preload("uid://bu74wfrxbow13")
var candycorn: PackedScene = preload("uid://e1hrcf4p5may")
var squabble: PackedScene = preload("uid://e1mwxdchlsyn")

@onready var candy_spawner: MultiplayerSpawner = $CandyCornBulletSpawner
@onready var sfx_spawner: MultiplayerSpawner = $SFXSpawner
@onready var player_sync_component: MultiplayerSynchronizer = $PlayerSyncComponent
@onready var collision_body: CollisionShape2D = $Body
@onready var ko_collision_body: CollisionShape2D = $KOBody
@onready var player_sync: MultiplayerSynchronizer = $PlayerSync
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var personal_space: Area2D = $PersonalSpace
@onready var camera_2d: Camera2D = $Camera2D
@onready var tag: Label = $tag
@onready var ui: Node2D = $UI

var player_active: bool = true
var squabbling: bool = false
var player_health: int = 50
var sprite_frames: int = 0
var total_costumes: int = 0
var user_name: String
var input_multiplayer_authority: int
var prev_anim: String
var speed: int = 500
var jump: int = -1000
var gravity: int = 13
var door_number: int
var opponent: Node2D = null
var sfx_stream = null

#run stats
var candy_gathered: int
var candy_robbed: int
var candy_lost: int
var candy_corn_gathered: int
var candy_corn_thrown: int
var houses_hit: int
var houses_revisited: int
var jumps: int
var dmg_dealt: float
var dmg_received: float
var dmg_blocked: float

func _ready() -> void:
	player_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	setup_individuals()
	personal_space.body_entered.connect(_on_player_collision)
	personal_space.body_exited.connect(_collision_reset)
	candy_spawner.spawn_function = func(data):
		var candy_corn = candycorn.instantiate()
		candy_corn.direction = data.direction - velocity.x
		if data.direction < 0:
			candy_corn.position.x -= 25
		else:
			candy_corn.position.x += 25
		return candy_corn
	sfx_spawner.spawn_function = func(data):
		var new_sfx = sfx_scene.instantiate()
		new_sfx.stream = data.sfx_stream
		return new_sfx

func setup_individuals():
	camera_2d.enabled = false
	if input_multiplayer_authority == multiplayer.get_unique_id():
		ui.top_right.visible = true
		camera_2d.enabled = true
		camera_2d.make_current()
		_set_costume_power_remote.rpc_id(1)
		_set_costume_power_local()
	tag.text = user_name
	animated_sprite_2d.sprite_frames = PlayerGlobals.costumes[sprite_frames]
	animated_sprite_2d.play()
	ui.update_health(player_health)

func _process(_delta: float) -> void:
	if squabbling and not has_node("Squabbling"): squabbling = false #sometimes this shit just sucks. idk.
	ui.update_health(player_health)
	if not animated_sprite_2d.is_playing(): animated_sprite_2d.play()
	if not is_multiplayer_authority(): return
	if not is_on_floor():
		velocity.y += gravity
	elif player_sync_component.jump:
		velocity.y = jump
	velocity.x = int(sign(player_sync_component.movement.x)) * ceil(abs(player_sync_component.movement.x)) * speed
	if prev_anim != player_sync_component.animation_select:
		animated_sprite_2d.animation = player_sync_component.animation_select
		prev_anim = animated_sprite_2d.animation
	move_and_slide()

func trick_or_treat():
	var doorbell_instance = doorbell.instantiate()
	if door_number not in PlayerGlobals.houses_hit[sprite_frames]:
		doorbell_instance.candy = 10
		doorbell_instance.candy_corn = 10
		PlayerGlobals.houses_hit[sprite_frames].append(door_number)
		candy_corn_gathered += 10
		candy_gathered += 10
		houses_hit += 1
	else:
		doorbell_instance.candy = 1
		doorbell_instance.candy_corn = 10
		candy_corn_gathered += 10
		candy_gathered += 1
		houses_revisited += 1
	add_child(doorbell_instance)

@rpc("any_peer", "call_local", "reliable")
func add_candy():
	PlayerGlobals.candy_count += 1

@rpc("any_peer", "call_local", "reliable")
func add_candy_corn():
	PlayerGlobals.candy_corn += 1

func _on_player_collision(body):
	if opponent: return
	if body is Player 			\
		and body != self 		\
		and player_active		\
		and body.player_active 	\
		and not body.squabbling:
		player_squabble(body)
		body.squabbling = true
		opponent = body
		
func _collision_reset(body):
	if body != opponent: return
	squabbling = false
	opponent = null
	if has_node("Squabble"):
		get_node("Squabble").queue_free()

func player_squabble(opp: Player):
	var squabble_instance = squabble.instantiate()
	squabble_instance.opponent = opp
	add_child(squabble_instance)
	if position.x < opp.position.x:
		animated_sprite_2d.animation = "squabble_right"
		player_sync_component.animation_select = "squabble_right"
	else: 
		animated_sprite_2d.animation = "squabble_left"
		player_sync_component.animation_select = "squabble_left"
	prev_anim = animated_sprite_2d.animation

@rpc("any_peer", "call_remote", "reliable")
func request_damage(amount: int):
	if multiplayer.is_server():
		apply_damage.rpc(amount)

@rpc("authority", "call_local", "reliable") 
func apply_damage(amount: int):
	player_health -= amount
	if player_health <= 0:
		player_health = 0
		player_active = false
		personal_space.monitoring = false
		ko_collision_body.call_deferred("set_disabled", false)
		collision_body.call_deferred("set_disabled", true)

func take_damage(amount: int):
	if multiplayer.is_server():
		apply_damage.rpc(amount)
	else:
		request_damage.rpc_id(1, amount)

@rpc("any_peer", "call_local", "reliable")
func sfx_all():
	if not multiplayer.is_server():
		return
	sfx_spawner.spawn({"sfx_stream": sfx_stream})

@rpc("any_peer", "call_local", "reliable")
func shoot_candy_corn(direction: int = 1000):
	if not multiplayer.is_server():
		return
	candy_spawner.spawn({"direction": direction})

@rpc("any_peer", "call_local", "reliable")
func _set_costume_power_remote():
	match sprite_frames:
		0:
			return
		1:
			sfx_stream = load("uid://b45fg0kwyq6yb")
		2: 
			speed = 5000
		3:
			return
		4:
			return
		5:
			return
		6:
			return
		7:
			return
		8:
			return
		9:
			return
		10:
			return
		11: 
			return

func _set_costume_power_local():
	match sprite_frames:
		0:
			return
		1:
			sfx_stream = load("uid://b45fg0kwyq6yb")
		2: 
			speed = 5000
		3:
			return
		4:
			return
		5:
			return
		6:
			return
		7:
			return
		8:
			return
		9:
			return
		10:
			return
		11: 
			return
