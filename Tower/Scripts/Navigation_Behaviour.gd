extends Sprite
signal goal_reached

var path
var current_index = 0
var path_behaviour
var environment
var timer = 0
export var movement_speed = 25

func connect_to_path(p_behaviour):
	environment = []	
	path_behaviour = p_behaviour
	path = path_behaviour.valid_path		
	current_index = path.size() - 1

func _process(delta):	
	if path.size() == 0 || path_behaviour == null || current_index < 0:
		return	
	timer += delta
	var travel_pos = path_behaviour.tiles[path_behaviour.get_navigation(path[current_index])].position
	look_at(travel_pos)
	var direction = travel_pos - position
	position += direction.normalized() * (delta * movement_speed)
	if position.distance_to(travel_pos) < 1:
		position = path_behaviour.tiles[path_behaviour.get_navigation(path[current_index])].position
		current_index -= 1
		if current_index < 0:
			emit_signal("goal_reached")
			queue_free()

func _on_Area2D_body_entered(body):
	queue_free()
	body.queue_free()
