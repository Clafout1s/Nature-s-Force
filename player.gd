
extends CharacterBody2D
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca

@export var SPEED = 400
@export var GRAVITY=200
var FLOOR = Vector2.UP


var jump_height=100.0
var jump_time=0.4
var jump_velocity= -(2.0 * jump_height) / jump_time
var gravity = (2.0*jump_height) / (jump_time**2) 

var screen_size
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = 500 #ProjectSettings.get_setting("physics/2d/default_gravity")
var shotgun_timer
var shotgun_value = 700
var shotgun_cd_timer
var shotgun_deceleration_timer
var is_jumping=false
var direction
var dash_direction
var shotgun_angle
var shotgun_cd=0.1
var shotgun_major_vect
var shotgun_deceleration=Vector2()
var shotgun_deceleration_value=Vector2()
var shotgun_deceleration_tps=0.5
var global_delta
var exp_gravity=0
 #nid,ndimension,nvalue_init,nframes_init,ndeceleration_speed
func _ready():
	set_floor_constant_speed_enabled(true)
	set_floor_snap_length(10)
	set_floor_max_angle(0.9)
	shotgun_timer = $ShotgunDashDuration
	shotgun_cd_timer = $ShotgunCd
	shotgun_deceleration_timer = $ShotgunDeceleration
	screen_size=get_viewport_rect().size

	
func _physics_process(delta):
	$gun.rotate_gun(position)
	global_delta = delta
	position.x=clamp(position.x,0,screen_size.x)
	position.y=clamp(position.y,0,screen_size.y)
	direction = Input.get_axis("left", "right")
	new_dash()
	
	if is_dashing():
		velocity.x=-cos(shotgun_angle)*shotgun_value
		velocity.y=-sin(shotgun_angle)*shotgun_value
		if is_jumping:
			is_jumping=false
	else:
		exp_gravity+=gravity * delta
		velocity.x=walk()
		velocity.y=exp_gravity
		jump()
		if is_jumping:
			velocity.y+=jump_velocity
		
		if is_decelerating():
			shotgun_deceleration.x=move_toward(shotgun_deceleration.x,0,abs(shotgun_deceleration_value.x))
			shotgun_deceleration.y=move_toward(shotgun_deceleration.y,0,abs(shotgun_deceleration_value.y))
			velocity.x+=shotgun_deceleration.x
			velocity.y+=shotgun_deceleration.y
			if direction != 0:
				shotgun_deceleration.x=0
				
	move_and_slide()
	print(velocity)
	if is_on_floor():
		is_jumping=false
		exp_gravity=0
		velocity.y=200

func new_dash():
	if Input.is_action_just_pressed("action1") and not is_shotgun_on_cd():
		$gun.blast()
		shotgun_angle =position.angle_to_point(get_global_mouse_position())
		shotgun_timer.start()
		shotgun_cd_timer.start()
		shotgun_deceleration.x=-cos(shotgun_angle)*shotgun_value
		shotgun_deceleration.y=-sin(shotgun_angle)*shotgun_value
		if abs(shotgun_deceleration.x)>abs(shotgun_deceleration.y):
			shotgun_major_vect="x"
		else:
			shotgun_major_vect="y"
		exp_gravity=0
func is_dashing():
	return !shotgun_timer.is_stopped()
func is_shotgun_on_cd():
	return !shotgun_cd_timer.is_stopped()
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

func _on_shotgun_dash_duration_timeout():
	velocity.y=0
	var tpf = shotgun_deceleration_tps*Performance.get_monitor(Performance.TIME_FPS)
	shotgun_deceleration_value.x = -cos(shotgun_angle)*shotgun_value / float(tpf)
	shotgun_deceleration_value.y = (-sin(shotgun_angle)*shotgun_value / float(tpf)) - (gravity*global_delta)
	shotgun_deceleration=Vector2(-cos(shotgun_angle)*shotgun_value,-sin(shotgun_angle)*shotgun_value)
	shotgun_deceleration_timer.set_wait_time(shotgun_deceleration_tps)
	shotgun_deceleration_timer.start()
func is_decelerating():
	return !shotgun_deceleration_timer.is_stopped()
