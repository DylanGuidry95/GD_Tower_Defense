extends Node2D

export var height = 25
export var width = 50

export var no_place_radius = 3
export var min_objective_distance = 7;

export (PackedScene) var tile

var random = RandomNumberGenerator.new()

var cells = []

var tiles = []

var start_node
var end_node

class MyCustomSorter:
	static func sort_ascending(a, b):
		if a.f_score < b.f_score:
			return true
		return false

class Cell:
	var position
	var traversable = true
	var h_score = 0
	var g_score = 0
	var f_score = 0
	var neighbors = []
	var parent = null
	
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
				
	func calc_h_score(destination):
		h_score = 10 * (abs(destination.position.x - position.x) + 
						abs(destination.position.y - position.y))
						
	func calc_f_score():
		f_score = g_score + h_score

func _ready():
	random.randomize()
	width = int((OS.window_size.x - (OS.window_size.x * .10)) / 18) 
	height = int((OS.window_size.y - (OS.window_size.y * .10)) / 18)
	for i in range(0, height):
		for j in range (0, width):
			var newCell = Cell.new()
			newCell.position = Vector2(j,i)
			cells.append(newCell)
	for c in cells:
		var newTile = tile.instance()
		tiles.append(newTile)	
		add_child(newTile)		
		newTile.position = c.position * Vector2(18,18) + newTile.position
		newTile.connect("tile_interacted", self, "tile_clicked")
		
	start_node = tiles[random.randi_range(0, tiles.size() / 2)]
	start_node.is_start = true
	end_node = tiles[random.randi_range(tiles.size() / 2, tiles.size() - 1)]
	var start = cells[tiles.find(start_node)]
	var end = cells[tiles.find(end_node)] 
	while start.position.distance_to(end.position) < min_objective_distance:
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
	
func _process(delta):
	if Input.is_action_just_pressed("run_sim"):
		if start_node != null && end_node != null:	
			for t in tiles:
				t.path = false
			reset()
			var path = find_path(cells[tiles.find(start_node)], cells[tiles.find(end_node)])
			for p in path:
				tiles[cells.find(p)].path = true

func find_path(start, goal):
	var openList = []
	var closedList = []	
	var currentNode
	currentNode = start
	openList.append(currentNode)
	while !closedList.has(goal) && openList.size() != 0:
		currentNode = openList[0]
		if currentNode.position == goal.position:
			break
		openList.remove(0)
		closedList.append(currentNode)
		var neighbors = get_neighbors(currentNode, closedList)
		for n in neighbors:
			if closedList.has(n):
				continue
			if !openList.has(n):
				n.calc_h_score(goal)
				n.calc_f_score()
				openList.append(n)		
		openList.sort_custom(MyCustomSorter, "sort_ascending")
	
	var n = goal
	var path = []
	while n != null:
		path.append(n)
		n = n.parent
	return path
		
func get_navigation(cell):
	return find_path(cell, end_node)
		
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
		c.parent = null

func tile_clicked(tile, state):
	var index = tiles.find(tile)
	var recalc = false
	if index != -1:
		if state == "traversable":
			for t in tiles:
				t.path = false
			cells[index].traversable = !cells[index].traversable
			tile.traversable = !tile.traversable
