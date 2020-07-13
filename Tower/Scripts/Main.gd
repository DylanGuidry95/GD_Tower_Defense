extends Node2D

export (PackedScene) var agent

var is_round_running
export var rounds = []
var num_spawns = 0
var current_round = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	is_round_running = false	
	pass # Replace with function body.

func _on_SpawnTimer_timeout():
	if is_round_running:	
		num_spawns += 1
		var new_agent = agent.instance()
		add_child(new_agent)
		new_agent.position = $Path.start_node.position
		new_agent.connect_to_path($Path)
	if num_spawns >= rounds[current_round]:
		is_round_running = false


func _on_HUD_round_start_pressed():
	is_round_running = true
	$Path.find_path()
	num_spawns = 0
