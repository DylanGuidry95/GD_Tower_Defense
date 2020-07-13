extends Sprite

var path
var current_index = 0
var path_behaviour
var environment
var timer = 0

func connect_to_path(p_behaviour):
	environment = []	
	path_behaviour = p_behaviour
	path = path_behaviour.valid_path
	current_index = path.size() - 1

func _process(delta):
	if path.size() == 0 || path_behaviour == null || current_index < 0:
		return
	timer += delta
	if timer >= 0.25:
		position = path_behaviour.tiles[path_behaviour.get_navigation(path[current_index])].position
		current_index -= 1
		timer = 0
