extends Node2D

var gun_centre_ecart=Vector2(10,15)
var gun_scale=Vector2(0.8,0.8)
# Called when the node enters the scene tree for the first time.
func _ready():
	scale=gun_scale


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func rotate_gun(point):
	var angle=point.angle_to_point(get_global_mouse_position())
	position=gun_centre_ecart*Vector2(cos(angle),sin(angle))
	transform.x=Vector2(cos(angle),sin(angle))
	transform.y=Vector2(-sin(angle),cos(angle))
	scale=gun_scale

func blast():
	print("BLAST !")
