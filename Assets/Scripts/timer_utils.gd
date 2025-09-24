class_name TimerUtils

# Creates a one-shot timer with callback
static func create_one_shot_timer(parent_node: Node, wait_time: float, callback: Callable) -> Timer:
	var timer = Timer.new()
	parent_node.add_child(timer)
	timer.wait_time = wait_time
	timer.one_shot = true
	timer.timeout.connect(callback)
	timer.start()
	return timer

# Creates a delayed function call using get_tree().create_timer
static func create_delayed_call(node: Node, wait_time: float, callback: Callable):
	await node.get_tree().create_timer(wait_time).timeout
	callback.call()

# Creates a repeating timer with callback
static func create_repeating_timer(parent_node: Node, wait_time: float, callback: Callable) -> Timer:
	var timer = Timer.new()
	parent_node.add_child(timer)
	timer.wait_time = wait_time
	timer.one_shot = false
	timer.timeout.connect(callback)
	timer.start()
	return timer

# Creates two timers for start/stop actions (like whip attack)
static func create_start_stop_timers(parent_node: Node, start_time: float, stop_time: float, start_callback: Callable, stop_callback: Callable) -> Array[Timer]:
	var start_timer = Timer.new()
	var stop_timer = Timer.new()

	parent_node.add_child(start_timer)
	parent_node.add_child(stop_timer)

	start_timer.wait_time = start_time
	start_timer.one_shot = true
	start_timer.timeout.connect(start_callback)

	stop_timer.wait_time = stop_time
	stop_timer.one_shot = true
	stop_timer.timeout.connect(stop_callback)

	return [start_timer, stop_timer]