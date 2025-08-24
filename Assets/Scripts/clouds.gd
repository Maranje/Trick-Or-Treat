extends Node2D

@onready var c1: Sprite2D = $Clouds1
@onready var c2: Sprite2D = $Clouds2
@onready var c3: Sprite2D = $Clouds3
@onready var c4: Sprite2D = $Clouds4
@onready var c5: Sprite2D = $Clouds5
@onready var c6: Sprite2D = $Clouds6

func _process(delta: float) -> void:
	c1.position.x += delta * 1
	c2.position.x += delta * 3
	c3.position.x += delta * 5
	c4.position.x += delta * 1
	c5.position.x += delta * 3
	c6.position.x += delta * 5
	
	if c1.position.x >= 800:
		c1.position.x = -1600
	elif c4.position.x >= 800:
		c4.position.x = -1600
	
	if c2.position.x >= 800:
		c2.position.x = -1600
	elif c5.position.x >= 800:
		c5.position.x = -1600
		
	if c3.position.x >= 800:
		c3.position.x = -1600
	elif c6.position.x >= 800:
		c6.position.x = -1600
