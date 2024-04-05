extends CharacterBody2D


@export var SPEED = 250.0
@export var GRAVITY=1500
@export var JUMP_VELOCITY = -500.0
@export var SHOTGUN_VELOCITY = SPEED*8

var shot_percent_reduction=20
var shotgun_shot=false
var actual_shot_velocity=0
var gun_centre_ecart
var down_velocity_modifier=40
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = GRAVITY #ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	gun_centre_ecart=Vector2(position.x-$gun.global_position.x,position.x-$gun.global_position.x)
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if Input.is_action_just_pressed("down") and not is_on_floor():
		velocity.y += (gravity * delta)*down_velocity_modifier
	apply_shotgun_physics()
	if shotgun_shot:
		var angle=position.angle_to_point(get_global_mouse_position())
		velocity=Vector2(-cos(angle), -sin(angle))*actual_shot_velocity
	else:
		horizontal_physics()
		jump_physics()
	
	shotgun_physics()
	
	

	move_and_slide()
	
	rotate_gun()

func horizontal_physics():
	var direction = Input.get_axis("left", "right")
	if direction and not (shotgun_shot and has_same_sign(velocity.x,actual_shot_velocity)):
		velocity.x = direction * SPEED 
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
		
func jump_physics():
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	

func shotgun_physics():
	if Input.is_action_just_pressed("action2"):
		shotgun_shot=true
		actual_shot_velocity=SHOTGUN_VELOCITY

func apply_shotgun_physics():
	if shotgun_shot:
		actual_shot_velocity-=shot_percent_reduction/float(100)*float(actual_shot_velocity)
		print(actual_shot_velocity)
		if actual_shot_velocity<=10/float(100)*float(SHOTGUN_VELOCITY):
			shotgun_shot=false
			actual_shot_velocity=0

func has_same_sign(f1:float,f2:float):
	return f1<0 and f2<0 or f1>0 and f2>0

func rotate_gun():
	var angle=position.angle_to_point(get_global_mouse_position())
	$gun.position =Vector2(cos(angle), sin(angle))*gun_centre_ecart
	$gun.look_at(get_global_mouse_position())

		
		
