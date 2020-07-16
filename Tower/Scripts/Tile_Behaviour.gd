extends Sprite

signal tile_interacted(arg, status)

var hoovered = false
var interactable = true
var traversable = true
export var has_resource = false
var path = false
var is_start = false
var is_goal = false

# Called when the node enters the scene tree for the first time.
func _ready():
	traversable = !has_resource
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hoovered && interactable && !is_start && !is_goal:
		if Input.is_action_just_pressed("place_turret") && !has_resource:
			emit_signal("tile_interacted", self, "traversable")
		if Input.is_action_just_pressed("place_turret") && has_resource:
			emit_signal("tile_interacted", self, "harvest")


func _on_Area2D_mouse_entered():
	hoovered = true

func _on_Area2D_mouse_exited():
	hoovered = false
