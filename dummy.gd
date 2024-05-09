extends CharacterBody2D

var hitable
signal hit
const SPEED = 300.0

var rotation_angle=0.959931
var rotation_speed=0.15

var screen_size

var rotation_instance=Regular_value.new("boing",rotation_angle,rotation_speed)


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	rotation_instance.add_followup(rotation_instance.pack_attributes(Regular_value.new("boing_back",-rotation_angle,rotation_speed)))
	screen_size=get_viewport_rect().size
	#$CollisionShape2D.set_deferred("disabled",true)

func _physics_process(delta):
	# Add the gravity.
	position=Vector2(clamp(position.x,0,screen_size.x),clamp(position.y,0,screen_size.y))
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("action2"):
		start_rotation()
	
	rotate(rotation_instance.return_value())
	
	
	move_and_slide()

func start_rotation():
	if not rotation_instance.activated:
		rotation_instance.start()


func _on_hit():
	start_rotation()
