class_name Player
extends CharacterBody2D

var doorbell: PackedScene = preload("uid://bx542d0joldxk")
var candycorn: PackedScene = preload("uid://e1hrcf4p5may")

@onready var player_sync_component: MultiplayerSynchronizer = $PlayerSyncComponent
@onready var player_sync: MultiplayerSynchronizer = $PlayerSync
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var tag: Label = $tag
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

func _ready() -> void:
	player_sync_component.set_multiplayer_authority(input_multiplayer_authority)
	
	for i in range(PlayerGlobals.costume_count):
		doors_hit.append([])
	
	setup_individuals()

func setup_individuals():
	camera_2d.enabled = false
	
	if input_multiplayer_authority == multiplayer.get_unique_id():
		camera_2d.enabled = true
		camera_2d.make_current()
		
	tag.text = user_name
	
	animated_sprite_2d.sprite_frames = PlayerGlobals.costumes[sprite_frames]
	animated_sprite_2d.play()

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("ui_up") 	\
		and player_sync_component.at_door 		\
		and not has_node("TrickOrTreat"):
			trick_or_treat(door_number)
			var doorbell_instance = doorbell.instantiate()
			add_child(doorbell_instance)
			print(doors_hit)
		
	if not is_multiplayer_authority(): return
	
	if not animated_sprite_2d.is_playing(): animated_sprite_2d.play()
		
	if not is_on_floor():
		velocity.y += gravity * delta
	elif player_sync_component.jump:
		velocity.y = jump
	velocity.x = player_sync_component.movement.x * speed
	if prev_anim != player_sync_component.animation_select:
		animated_sprite_2d.animation = player_sync_component.animation_select
		prev_anim = animated_sprite_2d.animation
	move_and_slide()
	
func trick_or_treat(door: int):
	PlayerGlobals.add_candy_corn(5)
	if door not in doors_hit[sprite_frames]:
		doors_hit[sprite_frames].append(door)

func shoot_candy_corn(direction: int = 1000):
	var candy_corn = candycorn.instantiate()
	candy_corn.direction = direction + velocity.x
	candy_corn.position.x += direction / 50
	add_child(candy_corn)
	PlayerGlobals.remove_one_candy_corn()
