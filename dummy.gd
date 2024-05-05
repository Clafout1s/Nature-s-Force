extends CharacterBody2D

var hitable
signal hit
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var rotation_started
var rotation_angle=6.28319
var rotation_speed=0.15
var rotation_value
var rotation_follow=0
var rotation_sign=1
var dummy_scale=Vector2(1.5,1.5)
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	scale=dummy_scale
	$CollisionShape2D.set_deferred("disabled",true)

func _physics_process(delta):
	# Add the gravity.
	"""
	if not is_on_floor():
		velocity.y += gravity * delta
	"""
	if Input.is_action_just_pressed("action2"):
		start_rotation()
	if rotation_started:
		rotate(rotation_value)
		rotation_follow+=rotation_value
	if abs(rotation_follow)>=abs(rotation_angle) and rotation_started:
		end_rotation()
	velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func start_rotation():
	rotation_started= ! rotation_started
	rotation_follow=0

	rotation_value=rotation_angle/float(rotation_speed * 60)
	print(rotation_value)


func end_rotation():
	rotation_started=false
	print(rotation_follow)
	rotation_follow=0
