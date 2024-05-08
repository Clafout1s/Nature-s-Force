
extends CharacterBody2D
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca

@export var SPEED = 400
@export var GRAVITY=200
var FLOOR = Vector2.UP

var hitable
signal hit

var jump_height=100.0
var jump_time=0.4
var jump_velocity= -(2.0 * jump_height) / jump_time
var gravity = (2.0*jump_height) / (jump_time**2) 

var screen_size
# Get the gravity from the project settings to be synced with RigidBody nodes.
#var gravity = 500 #ProjectSettings.get_setting("physics/2d/default_gravity")
var shotgun_timer
var shotgun_value = 1050
var shotgun_cd_timer
var shotgun_deceleration_timer
var is_jumping=false
var direction
var dash_direction
var shotgun_angle=0
var shotgun_cd=0.1
var shotgun_major_vect
var shotgun_deceleration=Vector2()
var shotgun_deceleration_value=Vector2()
var shotgun_tps=0.15
var shotgun_deceleration_tps=0.5
var global_delta
var exp_gravity=0

var shotgun_instance_x=Regular_value.new("shotgun_x",(-cos(shotgun_angle)*shotgun_value)*(shotgun_tps*60),shotgun_tps,true,shotgun_deceleration_tps)
var shotgun_instance_y=Regular_value.new("shotgun_y",(-sin(shotgun_angle)*shotgun_value)*(shotgun_tps*60),shotgun_tps,true,shotgun_deceleration_tps)
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
	
	global_delta = delta
	position.x=clamp(position.x,0,screen_size.x)
	position.y=clamp(position.y,0,screen_size.y)
	direction = Input.get_axis("left", "right")
	$gun.rotate_gun(position)
	new_dash()
	velocity.x=shotgun_instance_x.return_value()
	velocity.y=shotgun_instance_y.return_value()
	
	if not shotgun_instance_x.bursting and not shotgun_instance_y.bursting:
		exp_gravity+=gravity * delta
		
		velocity.x+=walk()
	if shotgun_instance_x.decelerating and shotgun_instance_y.decelerating:
		if not has_same_sign(direction,shotgun_instance_x.value_counter) and direction!=0:
			shotgun_instance_x.end_deceleration()
	velocity.y+=exp_gravity
	jump()
	if is_jumping:
		velocity.y+=jump_velocity

	move_and_slide()
	if is_on_floor():
		is_jumping=false
		exp_gravity=0
		#velocity.y=200

func new_dash():
	if Input.is_action_just_pressed("action1"):
		$gun.blast()
		shotgun_angle =position.angle_to_point(get_global_mouse_position())
		print((-cos(shotgun_angle)*shotgun_value)*(shotgun_tps*60))
		shotgun_instance_x=Regular_value.new("shotgun_x",(-cos(shotgun_angle)*shotgun_value)*(shotgun_tps*60),shotgun_tps,true,shotgun_deceleration_tps)
		shotgun_instance_y=Regular_value.new("shotgun_y",(-sin(shotgun_angle)*shotgun_value)*(shotgun_tps*60),shotgun_tps,true,shotgun_deceleration_tps)
		shotgun_instance_x.start()
		shotgun_instance_y.start()
		exp_gravity=0
		if is_jumping:
			is_jumping=false
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
	$gun.end_blast()
	var tpf = shotgun_deceleration_tps*Performance.get_monitor(Performance.TIME_FPS)
	print(Performance.get_monitor(Performance.TIME_FPS))
	shotgun_deceleration_value.x = -cos(shotgun_angle)*shotgun_value / float(tpf)
	shotgun_deceleration_value.y = (-sin(shotgun_angle)*shotgun_value / float(tpf)) - (gravity*global_delta)
	shotgun_deceleration=Vector2(-cos(shotgun_angle)*shotgun_value,-sin(shotgun_angle)*shotgun_value)
	shotgun_deceleration_timer.set_wait_time(shotgun_deceleration_tps)
	shotgun_deceleration_timer.start()
func is_decelerating():
	return !shotgun_deceleration_timer.is_stopped()
