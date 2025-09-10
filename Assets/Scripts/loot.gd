extends RigidBody2D

@onready var loot_sprite: Sprite2D = $LootSprite
var frame: int = 0

func _ready() -> void:
	var random_x_initial_inertia = (randi() % 200) - 100
	var random_y_initial_inertia = (randi() % 100) - 500
	loot_sprite.frame = frame
	contact_monitor = true
	max_contacts_reported = 10
	apply_impulse(Vector2(random_x_initial_inertia, random_y_initial_inertia))
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not multiplayer.is_server(): return
