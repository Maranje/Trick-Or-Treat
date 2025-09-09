extends Label
@export var source_number: String

func _ready() -> void:
	if source_number.is_empty():
		text = "0"
		return
	var value = PlayerGlobals.get(source_number)
	if value != null:
		text = str(value)
	else:
		text = "0"
		print("'%s' not found in PlayerGlobals :(" % source_number)

func update():
	var value = PlayerGlobals.get(source_number)
	if value != null:
		text = str(value)
	else:
		text = "0"
		print("'%s' not found in PlayerGlobals :(" % source_number)
