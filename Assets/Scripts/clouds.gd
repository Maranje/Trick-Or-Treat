extends Node2D

@onready var c1: Sprite2D = $Clouds1
@onready var c2: Sprite2D = $Clouds2
@onready var c3: Sprite2D = $Clouds3
@onready var c4: Sprite2D = $Clouds4
@onready var c5: Sprite2D = $Clouds5
@onready var c6: Sprite2D = $Clouds6

func _process(delta: float) -> void:
	c1.position.x += delta * GameConstants.CLOUD_SPEED_SLOW
	c2.position.x += delta * GameConstants.CLOUD_SPEED_MEDIUM
	c3.position.x += delta * GameConstants.CLOUD_SPEED_FAST
	c4.position.x += delta * GameConstants.CLOUD_SPEED_SLOW
	c5.position.x += delta * GameConstants.CLOUD_SPEED_MEDIUM
	c6.position.x += delta * GameConstants.CLOUD_SPEED_FAST
	
	if c1.position.x >= GameConstants.CLOUD_RIGHT_BOUND:
		c1.position.x = GameConstants.CLOUD_LEFT_BOUND
	elif c4.position.x >= GameConstants.CLOUD_RIGHT_BOUND:
		c4.position.x = GameConstants.CLOUD_LEFT_BOUND
	
	if c2.position.x >= GameConstants.CLOUD_RIGHT_BOUND:
		c2.position.x = GameConstants.CLOUD_LEFT_BOUND
	elif c5.position.x >= GameConstants.CLOUD_RIGHT_BOUND:
		c5.position.x = GameConstants.CLOUD_LEFT_BOUND
		
	if c3.position.x >= GameConstants.CLOUD_RIGHT_BOUND:
		c3.position.x = GameConstants.CLOUD_LEFT_BOUND
	elif c6.position.x >= GameConstants.CLOUD_RIGHT_BOUND:
		c6.position.x = GameConstants.CLOUD_LEFT_BOUND
