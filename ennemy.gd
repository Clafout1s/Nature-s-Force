extends CharacterBody2D


const SPEED = 8000
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var patrol_movement = Regular_value.new("patrol ennemy",0,1)
#nid,nvalue_init,ntps,nhas_deceleration=false,ndtps=0

signal floor_detection_question
signal wall_detection_question

var rng
var direction=0

func _ready():
	rng = RandomNumberGenerator.new()
	start_moving()
	scale.x = -1

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#velocity.x = patrol_movement.return_value()
	velocity.x = -100
	if velocity.x <0 and direction != -1:
		direction = -1
		scale.x=-1
	elif velocity.x >0  and direction != 1:
		direction = 1
		scale.x = -1

	if patrol_movement.just_finished:
		start_moving()
	
	emit_signal("floor_detection_question",direction)
	emit_signal("wall_detection_question",direction)
	move_and_slide()
	

func start_moving():
	patrol_movement.global_end()
	var value = rng.randi_range(3000,10000)
	
	var sign = rng.randi_range(-2,1)
	if sign < 0:
		sign = -1
	else:
		sign = 1
	
	patrol_movement.value_init=value*sign
	patrol_movement.tps = value / float(SPEED)
	patrol_movement.start()

func on_wall_detected():
	print("oh ma gahhhd")

func on_no_floor_detected():
	print("oh ma gahhhd on flooooor")
