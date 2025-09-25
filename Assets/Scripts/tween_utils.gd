class_name TweenUtils

# Creates a standard tween with common ease/transition settings
static func create_standard_tween(node: Node, tw_ease: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_CUBIC) -> Tween:
	var tween = node.create_tween()
	tween.set_ease(tw_ease)
	tween.set_trans(trans)
	return tween

# Creates a simple position tween
static func tween_position(node: Node, target: Vector2, duration: float, tw_ease: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_CUBIC) -> Tween:
	var tween = create_standard_tween(node, tw_ease, trans)
	tween.tween_property(node, "position", target, duration)
	return tween

# Creates a simple scale tween
static func tween_scale(node: Node, target: Vector2, duration: float, tw_ease: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_CUBIC) -> Tween:
	var tween = create_standard_tween(node, tw_ease, trans)
	tween.tween_property(node, "scale", target, duration)
	return tween

# Creates a simple modulate alpha tween
static func tween_fade(node: Node, target_alpha: float, duration: float, tw_ease: Tween.EaseType = Tween.EASE_IN_OUT, trans: Tween.TransitionType = Tween.TRANS_CUBIC) -> Tween:
	var tween = create_standard_tween(node, tw_ease, trans)
	tween.tween_property(node, "modulate:a", target_alpha, duration)
	return tween

# Creates a candy icon animation (common pattern)
static func create_candy_icon_tween(node: Node, destination: Vector2, travel_time: float) -> Tween:
	var tween = create_standard_tween(node, Tween.EASE_IN_OUT, Tween.TRANS_CUBIC)
	tween.tween_property(node, "position", destination, travel_time)
	tween.parallel().tween_property(node, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(node, "scale", Vector2(0.5, 0.5), travel_time)
	return tween

# Creates a candy UI animation (squabble pattern)
static func create_candy_ui_tween(node: Node, start_x: float, end_x: float, color_component: String) -> Tween:
	node.position.x = start_x
	var tween = create_standard_tween(node, Tween.EASE_IN_OUT, Tween.TRANS_EXPO)
	tween.tween_property(node, "position:x", end_x, 0.5)
	tween.parallel().tween_property(node, "modulate:" + color_component, 255, 0.5)
	return tween
