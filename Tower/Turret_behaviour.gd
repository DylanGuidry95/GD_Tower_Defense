extends Sprite

var closest_enemy

export var max_range = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

func _draw():
	draw_circle_arc(Vector2(0,0), max_range, 0, 360, Color.blue)	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	if closest_enemy == null || position.distance_to(closest_enemy.position) > max_range:
		var enemy = get_tree().get_nodes_in_group("mob")
		if enemy.size() > 0:
			closest_enemy = enemy[0]
			for e in enemy:
				if position.distance_to(e.position) < position.distance_to(closest_enemy.position):
					closest_enemy = e
					
	if closest_enemy != null:
		if position.distance_to(closest_enemy.position) <= max_range:
			look_at(closest_enemy.position)
