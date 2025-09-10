extends Node

var recent_ip: String = ""
var user_name: String = ""
var candy_count: int = 0
var candy_corn: int = 0
var costume_count: int = 12
var costumes_owned: Array = [0]
var current_costume: int = 0
var new_game: bool = true

var costumes = [
	preload("res://Assets/SpriteFrames/player_frames.tres"),
	preload("res://Assets/SpriteFrames/clown_frames.tres"),
	preload("res://Assets/SpriteFrames/cape_frames.tres"),
	preload("res://Assets/SpriteFrames/ninja_frames.tres"),
	preload("res://Assets/SpriteFrames/pants_frames.tres"),
	preload("res://Assets/SpriteFrames/nipple_frames.tres"),
	preload("res://Assets/SpriteFrames/faceless_frames.tres"),
	preload("res://Assets/SpriteFrames/egg_frames.tres"),
	preload("res://Assets/SpriteFrames/hole_frames.tres"),
	preload("res://Assets/SpriteFrames/unibrow_frames.tres"),
	preload("res://Assets/SpriteFrames/static_frames.tres"),
	preload("res://Assets/SpriteFrames/witch_hat_frames.tres")
]

const SAVE_FILE = "user://gamedata.save"

func _ready():
	load_data()
	candy_count = 0
	if new_game:
		_new_game()
		new_game = false
		save_data()
		return

func save_data():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var save_dict = {
			"new_game": new_game,
			"recent_ip": recent_ip,
			"user_name": user_name,
			"candy_count": candy_count,
			"candy_corn": candy_corn,
			"costume_count": costume_count,
			"current_costume": current_costume,
			"costumes_owned": costumes_owned
		}
		file.store_string(JSON.stringify(save_dict))
		file.close()

func load_data():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var loaded_data = json.data
				new_game = loaded_data.get("new_game")
				recent_ip = loaded_data.get("recent_ip", "")
				user_name = loaded_data.get("user_name", "")
				candy_count = loaded_data.get("candy_count", 0)
				candy_corn = loaded_data.get("candy_corn", 0)
				costume_count = loaded_data.get("costume_count", 12)
				current_costume = loaded_data.get("current_costume", 0)
				var loaded_costumes = loaded_data.get("costumes_owned", [0])
				costumes_owned = []
				for costume_id in loaded_costumes:
					costumes_owned.append(int(costume_id))

func _new_game():
	recent_ip = ""
	user_name = ""
	candy_count = 0
	candy_corn = 0
	costume_count = 12
	costumes_owned = [0]
	current_costume = 0
	new_game = true

# Convenience functions to update and save immediately
func edit_candy(amount: int):
	candy_count += amount
	save_data()

func edit_candy_corn(amount: int):
	candy_corn += amount
	save_data()
