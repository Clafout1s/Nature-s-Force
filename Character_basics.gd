extends CharacterBody2D
class_name Character_basics

var speed = 400
var gravity = 1633
var exp_gravity = 0
var screen_size
var tempoclamp
var spawn_point = Vector2(0,0)
signal hit
var type = "ennemy"
var direction = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	set_floor_constant_speed_enabled(true)
	set_floor_snap_length(10)
	set_floor_max_angle(0.9)
	screen_size=get_viewport_rect().size
	position = spawn_point
	hit.connect(_on_hit)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	tempoclamp=Vector2(clamp(position.x,0,screen_size.x),clamp(position.y,0,screen_size.y))
	if position.x != tempoclamp.x:
		position.x=tempoclamp.x
		tempoclamp_addon_x()
	if position.y != tempoclamp.y:
		position.y = tempoclamp.y
		tempoclamp_addon_y()
	
	process_addon(delta)
	
	move_and_slide()
	
	if is_on_floor():
		on_floor_addon()
	
	
func tempoclamp_addon_x():
	pass
func tempoclamp_addon_y():
	pass
func _on_hit():
	pass

func process_addon(delta):
	exp_gravity += gravity*delta
	velocity.y = exp_gravity

func on_floor_addon():
	exp_gravity = 0
