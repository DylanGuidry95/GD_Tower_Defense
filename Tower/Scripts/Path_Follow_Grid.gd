extends Node2D

export var height = 25
export var width = 50

export var no_place_radius = 3
export var min_objective_distance = 7;
export var height_mod = 5

export (PackedScene) var tile
export (PackedScene) var mountain
export (PackedScene) var water
export (PackedScene) var turret
export (PackedScene) var harvester
export (PackedScene) var wood
export (PackedScene) var stone

var random = RandomNumberGenerator.new()

var cells = []

var tiles = []

var start_node
var end_node

var valid_path

class MyCustomSorter:
	static func sort_ascending(a, b):
		if a.f_score < b.f_score:
			return true
		return false

class Cell:
	var position
	var height
	var traversable = true
	var h_score = 0
	var g_score = 0
	var f_score = 0
	var neighbors = []
	var parent = null
	var child = null
	
	func reset():
		g_score = 0
		h_score = 0
		f_score = 0
		neighbors = [null, null]
		parent = null
	
	func calc_g_score(from):
		var g = 0
		var h_v_positions = [position - Vector2(-1,0),
							position - Vector2(1,0),
							position - Vector2(0,1),
							position - Vector2(0, -1)]
		var d_positions = [position - Vector2(1,1),
							position - Vector2(-1,1),
							position - Vector2(1,-1),
							position - Vector2(-1,-1)]
		for p in h_v_positions:
			if from.position == p:
				g = 10
		for p in d_positions:
			if from.position == p:
				g = 14
		if parent == null:
			parent = from
			g_score = parent.g_score + g
		else:
			if g_score > from.g_score + g:
				parent = from
				g_score = parent.g_score + g
		parent.child = self	
				
	func calc_h_score(destination):
		h_score = (10 + height) * (abs(destination.position.x - position.x) + 
						abs(destination.position.y - position.y))

	func calc_f_score():
		f_score = g_score + h_score

func _ready():
	random.randomize()
	var noise = OpenSimplexNoise.new()
	noise.seed = random.randi()
	noise.octaves = 3
	noise.period = 20
	noise.persistence = 0.8	
	width = int((OS.window_size.x - (OS.window_size.x * .10)) / 18) 
	height = int((OS.window_size.y - (OS.window_size.y * .10)) / 18)
	for i in range(0, height):
		for j in range (0, width):
			var newCell = Cell.new()
			newCell.position = Vector2(j,i)
			cells.append(newCell)

	for c in cells:		
		var pos = c.position * Vector2(16,16)
		c.height = noise.get_noise_2dv(pos) * height_mod
		var newTile
		if c.height > 1.5:
			newTile = mountain.instance()
		elif c.height < -1:
			newTile = water.instance()
			c.traversable = false
			newTile.traversable = false
		else:
			newTile = tile.instance()
		tiles.append(newTile)	
		add_child(newTile)		
		newTile.position = pos + newTile.position
		newTile.connect("tile_interacted", self, "tile_clicked")
		var h = c.height
		var mat = newTile.material
		
	start_node = tiles[random.randi_range(0, tiles.size() / 2)]
	var start = cells[tiles.find(start_node)]
	while !start.traversable:
		start_node = tiles[random.randi_range(0, tiles.size() / 2)]
		start = cells[tiles.find(start_node)]
	start_node.is_start = true
	end_node = tiles[random.randi_range(tiles.size() / 2, tiles.size() - 1)]	
	var end = cells[tiles.find(end_node)] 
	while start.position.distance_to(end.position) < min_objective_distance || !end.traversable:
		end_node = tiles[random.randi_range(tiles.size() / 2, tiles.size() - 1)]
		end = cells[tiles.find(end_node)]
	end_node.is_goal = true
	
	for c in cells:
		var s = cells[tiles.find(start_node)]
		var e = cells[tiles.find(end_node)]
		if s.position.distance_to(c.position) <= no_place_radius:
			tiles[cells.find(c)].interactable = false
		if e.position.distance_to(c.position) <= no_place_radius:
			tiles[cells.find(c)].interactable = false	
	place_resources(3, 3)

func place_resources(num_wood, num_stone):
	for i in range(0, num_wood):
		var index = random.randi_range(0, tiles.size() - 1)
		var is_start_node = tiles[index].position == start_node.position
		var is_end_node = tiles[index].position == end_node.position
		var is_trav = tiles[index].traversable
		while !is_trav:
			index = random.randi_range(0, tiles.size() - 1)
			is_trav = tiles[index].traversable
		tiles[index].has_resource = true
		var w = wood.instance()
		add_child(w)
		w.position = tiles[index].position
	for i in range(0, num_stone):
		var index = random.randi_range(0, tiles.size() - 1)
		var is_start_node = tiles[index].position == start_node.position
		var is_end_node = tiles[index].position == end_node.position
		var is_not_trav = !tiles[index].traversable
		while is_not_trav:
			index = random.randi_range(0, tiles.size() - 1)
			is_not_trav = tiles[index].traversable
		tiles[index].has_resource = true
		var s = stone.instance()
		add_child(s)
		s.position = tiles[index].position

func find_path():
	reset()
	var openList = []
	var closedList = []	
	var currentNode
	currentNode = cells[tiles.find(start_node)]
	openList.append(currentNode)
	
	var iter = 0
	
	while !closedList.has(cells[tiles.find(end_node)]) && openList.size() != 0:
		iter += 1
		currentNode = openList[0]
		if currentNode.position == cells[tiles.find(end_node)].position:
			break
		openList.remove(0)
		closedList.append(currentNode)
		var neighbors = get_neighbors(currentNode, closedList)
		for n in neighbors:
			if closedList.has(n):
				continue
			if !openList.has(n):
				n.calc_h_score(cells[tiles.find(end_node)])
				n.calc_f_score()
				openList.append(n)		
		openList.sort_custom(MyCustomSorter, "sort_ascending")
	
	if openList.size() == 0:
		print("NO PATH")
	var n = cells[tiles.find(end_node)]
	var path = []
	while n != null:
		path.append(n)
		n = n.parent
	valid_path = path
	update()
	
func get_navigation(cell):
	for c in cells:
		if c.position == cell.position:
			return cells.find(c)
		
func sort_open_list(list):
	for cell in list:
		for c in list:			
			if cell.f_score < c.f_score:
				var temp = cell
				cell = c
				c = temp
		
func get_neighbors(node, closed_list):
	var neighborPos = [node.position + Vector2(0,1),
					node.position + Vector2(0,-1),
					node.position + Vector2(1,0),
					node.position + Vector2(-1,0),
					node.position + Vector2(1,1),
					node.position + Vector2(1,-1),
					node.position + Vector2(-1,-1),
					node.position + Vector2(-1,1)]
	
	var neighbors = []
	for c in cells:
		if closed_list.has(c) || !c.traversable:
			continue
		for n in neighborPos:
			if c.position == n:
				neighbors.append(c)
				node.neighbors.append(c)
				c.calc_g_score(node)
				break	
	return neighbors

func reset():
	for c in cells:
		c.reset()

func tile_clicked(i_tile, state):
	var m = get_parent()
	valid_path = []
	if !m.is_round_running:
		var index = tiles.find(i_tile)
		var recalc = false
		if index != -1:
			if state == "traversable":
				for t in tiles:
					t.path = false
				cells[index].traversable = false
				i_tile.traversable = false
				var t = turret.instance()
				get_parent().add_child(t)
				t.position = i_tile.position
			if state == "harvest":
				for t in tiles:
					t.path = false
				var h = harvester.instance()
				get_parent().add_child(h)
				h.position = i_tile.position
		update()

func _draw():
	draw_circle_arc(start_node.position, no_place_radius * 16, 0, 360, Color.black)
	draw_circle_arc(end_node.position, no_place_radius * 16, 0, 360, Color.black)	
	var path = valid_path
	if path != null:
		if path.size() != 0:
			var iter = 0
			for tile in path:
				if iter == path.size() - 1:
					break
				draw_line(tiles[get_navigation(path[iter])].position, tiles[get_navigation(path[iter + 1])].position, Color.black)
				iter += 1
	
	
func draw_circle_arc(center, radius, angle_from, angle_to, color):
	var nb_points = 32
	var points_arc = PoolVector2Array()

	for i in range(nb_points + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	for index_point in range(nb_points):
		draw_line(points_arc[index_point], points_arc[index_point + 1], color)
