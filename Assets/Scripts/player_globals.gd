extends Node

# Global properties
var user_name: String = ""
var candy_count: int = 0
var candy_corn: int = 0
var current_costume: int = 0

const SAVE_FILE = "user://gamedata.save"

func _ready():
	load_data()

func save_data():
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var save_dict = {
			"user_name": user_name,
			"candy_count": candy_count,
			"candy_corn": candy_corn,
			"current_costume": current_costume
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
				user_name = loaded_data.get("user_name", "")
				candy_count = loaded_data.get("candy_count", 0)
				candy_corn = loaded_data.get("candy_corn", 0)
				current_costume = loaded_data.get("current_costume", 0)

# Convenience functions to update and save immediately
func add_candy(amount: int):
	candy_count += amount
	save_data()

func add_candy_corn(amount: int):
	candy_corn += amount
	save_data()

func set_costume(costume_id: int):
	current_costume = costume_id
	save_data()

func set_username(username: String):
	user_name = username
	save_data()
