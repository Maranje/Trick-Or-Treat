extends RigidBody2D
var direction: int = 1000

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 10
	
	apply_impulse(Vector2(direction, -100))
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Hit: ", body.name)
	queue_free()
