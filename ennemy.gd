extends CharacterBody2D

var spawn_point = Vector2(0,0)
signal hit
var hitable
var ennemy

var space_state 
const SPEED = 200
const JUMP_VELOCITY = -400.0
var screen_size
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 1632.65306122449
var exp_gravity=0
signal no_floor_detected
signal wall_detected

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
	exp_gravity += gravity * delta
	tempoclamp=Vector2(clamp(position.x,0,screen_size.x),clamp(position.y,0,screen_size.y))
	if position.x != tempoclamp.x:
		position.x = tempoclamp.x
		if state == idle :
			swap()
	if position.y != tempoclamp.y:
		position.y = tempoclamp.y
		
	if checking_for_player:
		if state==idle:
			if raycast_to_player():
				switch_to_attack()
		elif state == attack:
			if not raycast_to_player():
				switch_to_idle()
	
	if not is_on_floor():
		velocity.y = exp_gravity
	else:
		exp_gravity = 0
	if state == idle:
		velocity.x = SPEED * direction
	elif state == attack:
		var tempo = player_body.global_position.x - global_position.x 
		tempo = into_sign(tempo)
		if not has_same_sign(tempo,direction):
			swap()
		velocity.x = tempo * (SPEED * 200/float(100))
	move_and_slide()

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
	if not $vision/CollisionShape2D.disabled:
		checking_for_player=false

func raycast_to_player():
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(position, player_body.position)
	var result = space_state.intersect_ray(query)
	if result != {} and "player" in result["collider"] :
		return true
	return false

func switch_to_idle():
	state = idle
	checking_for_player = false
	$vision/CollisionShape2D.set_deferred("disabled",false)

func switch_to_attack():
	checking_for_player = false
	state = attack
	$vision/CollisionShape2D.set_deferred("disabled",true)
	checking_for_player = true
	
func has_same_sign(f1:float,f2:float):
	return f1<0 and f2<0 or f1>0 and f2>0
func into_sign(f1:float):
	f1 = int(f1)
	if f1<0:
		return -1
	elif f1>0:
		return 1
	else:
		return 0

func _on_damage_zone_body_entered(body):
	if "hitable" in body:
		body.emit_signal("hit")


func _on_hit():
	position = spawn_point
	switch_to_idle()

func _on_no_floor_detected():
	if state == idle:
		swap()

func _on_wall_detected():
	if state == idle:
		swap()
