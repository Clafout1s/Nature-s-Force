
extends CharacterBody2D
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca

@export var SPEED = 400
@export var GRAVITY=1800
@export var JUMP_VELOCITY = -500.0

var screen_size
var gun_centre_ecart
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = GRAVITY #ProjectSettings.get_setting("physics/2d/default_gravity")
var exp_gravity=0
var shotgun_timer
var jump_value=-1000
var is_jumping=false
var direction

 #nid,ndimension,nvalue_init,nframes_init,ndeceleration_speed
func _ready():
	shotgun_timer = $ShotgunDashDuration
	screen_size=get_viewport_rect().size
	gun_centre_ecart=Vector2(position.x-$gun.global_position.x,position.x-$gun.global_position.x)
	
func _physics_process(delta):
	rotate_gun()
	position.x=clamp(position.x,0,screen_size.x)
	position.y=clamp(position.y,0,screen_size.y)
	direction = Input.get_axis("left", "right")
	exp_gravity+=gravity*delta
	new_dash()
	jump()
	if is_dashing():
		velocity.x=direction*1000
		velocity.y=0
		exp_gravity=0
		if is_jumping==true:
			is_jumping=false
	else:	
		velocity.x=walk()
	velocity.y=exp_gravity
	if is_jumping:
		velocity.y+=jump_value
	
	move_and_slide()
	if is_on_floor():
		exp_gravity=gravity*delta
		is_jumping=false
		
func new_horizontal():
	pass
func new_vertical(delta):
	exp_gravity+=gravity*delta
	pass
func new_dash():
	if Input.is_action_just_pressed("action1"):
		shotgun_timer.start()
func is_dashing():
	return !shotgun_timer.is_stopped()
	
func walk():
	if direction:
		return direction * SPEED 
	else:
		return 0
func jump():
	if Input.is_action_just_pressed("up") and is_on_floor():
		is_jumping=true
		
func has_same_sign(f1:float,f2:float):
	return f1<0 and f2<0 or f1>0 and f2>0

func rotate_gun():
	var angle=position.angle_to_point(get_global_mouse_position())
	$gun.position =Vector2(cos(angle), sin(angle))*gun_centre_ecart
	$gun.look_at(get_global_mouse_position())
