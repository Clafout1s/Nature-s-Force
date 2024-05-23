extends Character_basics

var space_state 
const SPEED = 200
signal no_floor_detected
signal wall_detected

var checking_for_player = false
var player_body
var ready_to_swap = false
var state = idle
enum {
	idle,
	attack
}
func _ready():
	super()
	space_state= get_world_2d().direct_space_state
	direction = 1
func tempoclamp_addon_x():
	if state == idle :
		swap()

func process_addon(delta):
	exp_gravity += gravity*delta
	
	if checking_for_player:
		if state==idle:
			if raycast_to_player():
				switch_to_attack()
		elif state == attack:
			if not raycast_to_player():
				switch_to_idle()

	if state == idle:
		velocity.x = SPEED * direction
	elif state == attack:
		var tempo = player_body.global_position.x - global_position.x 
		if abs(tempo) > 80:
			tempo = into_sign(tempo)
		else:
			tempo = direction

		if not has_same_sign(tempo,direction):
			swap()

		velocity.x = tempo * (SPEED * 200/float(100))

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
	if player_body != null and state == attack:
		print(player_body.position - position)
	direction *= -1
	$Sprite2D.scale.x *= -1
	#swap_direction_collisions()


func _on_vision_body_entered(body):
	if "type" in body and body.type == "player":
		checking_for_player=true
		player_body = body
		
func _on_vision_body_exited(body):
	if not $vision/CollisionShape2D.disabled:
		checking_for_player=false

func raycast_to_player():
	# use global coordinates, not local to node
	var query = PhysicsRayQueryParameters2D.create(position, player_body.position)
	var result = space_state.intersect_ray(query)
	if result != {} and "type" in result["collider"] and result["collider"].type == "player":
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
