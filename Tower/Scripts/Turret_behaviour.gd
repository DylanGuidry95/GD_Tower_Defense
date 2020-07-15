extends Sprite

var closest_enemy = null

var fire_timer
export (PackedScene) var projectille

export var max_range = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	fire_timer = $timer

func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if closest_enemy == null || position.distance_to(closest_enemy.position) > max_range:
		var enemy = get_tree().get_nodes_in_group("mob")
		if enemy.size() > 0:						
			for e in enemy:
				if closest_enemy == null:
					if position.distance_to(e.position) <= max_range:
						closest_enemy = e
				if position.distance_to(e.position) <= max_range && closest_enemy != null:					
					if position.distance_to(e.position) < position.distance_to(closest_enemy.position):
						closest_enemy = e
	if closest_enemy != null:
		if position.distance_to(closest_enemy.position) <= max_range:
			look_at(closest_enemy.position)	

func _on_Timer_timeout():
	if closest_enemy != null:
		var proj = projectille.instance()
		get_parent().add_child(proj)
		proj.rotation = rotation
		proj.position = self.global_position
		var dir = closest_enemy.position - position
		proj.linear_velocity = Vector2(500, 0)
		proj.linear_velocity = proj.linear_velocity.rotated(rotation)
