extends Node2D
export (PackedScene) var agent
export (PackedScene) var path_visual
export (PackedScene) var spawner_visual
export (PackedScene) var goal_visual

var is_round_running
export var rounds = []
var num_spawns = 0
var current_round = 0
var spawner
var goal
var paths = []

export var health = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	is_round_running = false
	var algo = $Path
	spawner = spawner_visual.instance()
	add_child(spawner)
	spawner.position = algo.start_node.position			
	goal = goal_visual.instance()
	add_child(goal)
	goal.position = algo.end_node.position

func _on_SpawnTimer_timeout():
	if is_round_running:	
		num_spawns += 1
		var new_agent = agent.instance()
		add_child(new_agent)
		new_agent.position = $Path.start_node.position
		new_agent.connect_to_path($Path)
		new_agent.connect("goal_reached", self, "take_damage")
	if num_spawns >= rounds[current_round]:
		is_round_running = false

func _process(delta):
	update()
	if Input.is_action_just_pressed("show path") && !is_round_running:		
		$Path.find_path()

func _draw():
	var path = $Path.valid_path
	if path != null:
		if path.size() != 0:
			var iter = 0
			for tile in path:
				if iter == path.size() - 1:
					break
				draw_line($Path.tiles[tile, path[iter + 1].position, Color.black)
				iter += 1

func take_damage():
	health -= 1
	print(health)

func _on_HUD_round_start_pressed():
	is_round_running = true	
	$Path.find_path()
	num_spawns = 0
	current_round += 1
