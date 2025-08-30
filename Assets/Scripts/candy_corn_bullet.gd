extends RigidBody2D
var direction: int = 1000

func _ready() -> void:
	# Enable contact monitoring
	contact_monitor = true
	max_contacts_reported = 10
	
	apply_impulse(Vector2(direction, -100))
	
	# Connect signals
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Hit: ", body.name)
	queue_free()  # Remove projectile on hit
