extends CharacterBody2D


const SPEED = 200
const JUMP_VELOCITY = -400.0
var screen_size
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var patrol_movement = Regular_value.new("patrol ennemy",0,1)
#nid,nvalue_init,ntps,nhas_deceleration=false,ndtps=0

signal floor_detection_question
signal wall_detection_question

var rng
var direction=1
var tempoclamp
var ready_to_swap = false
func _ready():
	rng = RandomNumberGenerator.new()
	screen_size=get_viewport_rect().size
	$vision/area_left.set_deferred("disabled",true)
	$vision/area_left.set_deferred("visible",false)
func _physics_process(delta):
	# Add the gravity.
	tempoclamp=Vector2(clamp(position.x,0,screen_size.x),clamp(position.y,0,screen_size.y))
	if position.x != tempoclamp.x:
		swap()
		
	if not is_on_floor():
		velocity.y += gravity * delta
	
	velocity.x = SPEED * direction
	
	emit_signal("floor_detection_question",direction)
	emit_signal("wall_detection_question",direction)
	move_and_slide()
	

func on_wall_detected():
	swap()

func on_no_floor_detected():
	swap()

func swap_direction_collisions():
	if $vision/area_left.disabled:
		$vision/area_left.set_deferred("disabled",false)
		$vision/area_right.set_deferred("disabled",true)
		$vision/area_left.set_deferred("visible",true)
		$vision/area_right.set_deferred("visible",false)
	elif $vision/area_right.disabled:
		$vision/area_left.set_deferred("disabled",true)
		$vision/area_right.set_deferred("disabled",false)
		$vision/area_left.set_deferred("visible",false)
		$vision/area_right.set_deferred("visible",true)

func swap():
	direction *= -1
	$Sprite2D.scale.x *= -1
	swap_direction_collisions()
