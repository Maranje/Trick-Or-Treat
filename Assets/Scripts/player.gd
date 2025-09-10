class_name Player
extends CharacterBody2D

var doorbell: PackedScene = preload("uid://bx542d0joldxk")
var candycorn: PackedScene = preload("uid://e1hrcf4p5may")
var squabble: PackedScene = preload("uid://e1mwxdchlsyn")
var loot: PackedScene = preload("uid://cn7qqf8r4561v")
@onready var candy_spawner: MultiplayerSpawner = $CandyCornBulletSpawner
@onready var loot_spawner: MultiplayerSpawner = $LootSpawner
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
var gravity: int = 2500
var door_number: int
var doors_hit: Array[Array]
var opponent: Node2D = null

#run stats
var candy_gathered: int#
var candy_robbed: int#
var candy_lost: int#
var candy_corn_gathered: int#
var candy_corn_thrown: int#
var houses_hit: int#
var houses_revisited: int#
var jumps: int#
var dmg_dealt: float#
var dmg_received: float#
var dmg_blocked: float#

func _ready() -> void:
	player_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	for i in range(PlayerGlobals.costume_count):
		doors_hit.append([])
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
	loot_spawner.spawn_function = func(data):
		var new_loot = loot.instantiate()
		new_loot.frame = data.frame
		return new_loot

func setup_individuals():
	camera_2d.enabled = false
	if input_multiplayer_authority == multiplayer.get_unique_id():
		ui.top_right.visible = true
		camera_2d.enabled = true
		camera_2d.make_current()
	tag.text = user_name
	animated_sprite_2d.sprite_frames = PlayerGlobals.costumes[sprite_frames]
	animated_sprite_2d.play()
	ui.update_health(player_health)

func _process(delta: float) -> void:
	if squabbling and not has_node("Squabbling"): squabbling = false #sometimes this shit just sucks. idk.
	ui.update_health(player_health)
	if not animated_sprite_2d.is_playing(): animated_sprite_2d.play()
	if not is_multiplayer_authority(): return
	if not is_on_floor():
		velocity.y += gravity * delta
	elif player_sync_component.jump:
		velocity.y = jump
	velocity.x = player_sync_component.movement.x * speed
	if prev_anim != player_sync_component.animation_select:
		animated_sprite_2d.animation = player_sync_component.animation_select
		prev_anim = animated_sprite_2d.animation
	move_and_slide()

func trick_or_treat():
	var doorbell_instance = doorbell.instantiate()
	if door_number not in doors_hit[sprite_frames]:
		doorbell_instance.candy = 10
		doorbell_instance.candy_corn = 10
		doors_hit[sprite_frames].append(door_number)
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

func player_edit_candy(amount: int):
	PlayerGlobals.edit_candy(amount)

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
		call_deferred("drop_loot", PlayerGlobals.candy_corn, PlayerGlobals.candy_count)

func take_damage(amount: int):
	if multiplayer.is_server():
		apply_damage.rpc(amount)
	else:
		request_damage.rpc_id(1, amount)

@rpc("authority", "call_local", "reliable")
func drop_loot(corn_count: int, candy_count: int):
	if not multiplayer.is_server():
		return
	for i in corn_count:
		loot_spawner.spawn({"frame": 1})
	for i in candy_count:
		loot_spawner.spawn({"frame": 0})
	PlayerGlobals.candy_corn = 0
	PlayerGlobals.candy_count = 0

@rpc("any_peer", "call_local", "reliable")
func shoot_candy_corn(direction: int = 1000):
	if not multiplayer.is_server():
		return
	candy_spawner.spawn({"direction": direction})
