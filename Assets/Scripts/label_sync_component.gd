extends MultiplayerSynchronizer

var label_text: String
var p_ready: bool = false

func gather_input(text: String):
	if is_multiplayer_authority():
		label_text = text

func player_ready():
	if is_multiplayer_authority():
		p_ready = !p_ready
