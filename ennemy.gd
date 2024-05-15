extends CharacterBody2D

var space_state 
const SPEED = 200
const JUMP_VELOCITY = -400.0
var screen_size
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
#var patrol_movement = Regular_value.new("patrol ennemy",0,1)
#nid,nvalue_init,ntps,nhas_deceleration=false,ndtps=0

signal floor_detection_question
signal wall_detection_question

var checking_for_player = false
var player_body
var rng
var direction=1
var tempoclamp
var ready_to_swap = false
var state = idle
enum {
	idle,
	attack
}
func _ready():
	space_state= get_world_2d().direct_space_state
	rng = RandomNumberGenerator.new()
	screen_size=get_viewport_rect().size
	#$vision/area_left.set_deferred("disabled",true)
	#$vision/area_left.set_deferred("visible",false)
func _physics_process(delta):
	# Add the gravity.
	tempoclamp=Vector2(clamp(position.x,0,screen_size.x),clamp(position.y,0,screen_size.y))
	if position.x != tempoclamp.x:
		swap()
	
	if checking_for_player:
		if raycast_to_player():
			switch_to_attack()
	
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
	#swap_direction_collisions()


func _on_vision_body_entered(body):
	if "player" in body:
		checking_for_player=true
		player_body = body
		
func _on_vision_body_exited(body):
	checking_for_player=false

func raycast_to_player():
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(position, player_body.position)
	var result = space_state.intersect_ray(query)
	if "player" in result["collider"] :
		return true
	return false

func switch_to_idle():
	state = idle
	$vision/CollisionShape2D.set_deferred("disabled",false)

func switch_to_attack():
	print("graou attacc !!!")
	checking_for_player = false
	state = attack
	$vision/CollisionShape2D.set_deferred("disabled",true)
