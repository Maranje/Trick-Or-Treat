extends RigidBody2D

var direction: Vector2

@onready var egg_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	egg_sprite.animation = "egg"
	contact_monitor = true
	max_contacts_reported = 10
	apply_impulse(direction)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not multiplayer.is_server(): return
	if "player_health" in body and body.player_health > 0:
		body.apply_damage.rpc_id(1, 5)
		#if direction.x < 0:
			#egg_sprite.animation = "egg_hit_vert_right"
		#elif direction.x > 0:
			#egg_sprite.animation = "egg_hit_vert_left"
		#egg_sprite.play()
	#else:
		#egg_sprite.animation = "egg_hit_horz"
	queue_free()
