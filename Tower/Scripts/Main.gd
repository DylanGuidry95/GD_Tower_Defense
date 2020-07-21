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
	algo.create_environment()
	spawner = spawner_visual.instance()
	spawner.visible = false
	add_child(spawner)
	spawner.position = algo.start_node.position		
	goal = goal_visual.instance()
	goal.visible = false
	add_child(goal)
	goal.position = algo.end_node.position
	pop_in_tiles()

func pop_in_tiles():
	for t in range(0, $Path.tiles.size()):
		$Path.tiles[t].visible = true
		t += 1
		if t % $Path.width == 0:
			var timer = Timer.new()
			timer.set_wait_time(0.1)
			timer.set_one_shot(true)
			self.add_child(timer)
			timer.start()
			yield(timer, "timeout")
			timer.queue_free()
	goal.visible = true
	spawner.visible = true
	$Path.place_resources(10,6)

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
	if Input.is_action_just_pressed("show path") && !is_round_running:		
		$Path.find_path()
	if Input.is_action_just_pressed("reset game") && !is_round_running:
		reset_game()

func reset_game():
	goal.visible = false
	spawner.visible = false
	$Path.create_environment()
	current_round = 0
	pop_in_tiles()
	goal.position = $Path.end_node.position
	spawner.position = $Path.start_node.position	

func take_damage():
	health -= 1
	print(health)

func _on_HUD_round_start_pressed():
	is_round_running = true	
	$Path.find_path()
	num_spawns = 0
	current_round += 1
