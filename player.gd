
extends Character_basics
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca

var jump_height=100.0
var jump_time=0.35
var jump_velocity= -(2.0 * jump_height) / jump_time
var just_jumping = false
var is_jumping=false
var shotgun_value = 1050
var shotgun_angle=0
var shotgun_tps=0.15
var shotgun_deceleration_tps=0.8
var shotgun_cd_timer
var shotgun_instance_x=Regular_value.new("shotgun_x",(-cos(shotgun_angle)*shotgun_value)*(shotgun_tps*60),shotgun_tps,true,shotgun_deceleration_tps)
var shotgun_instance_y=Regular_value.new("shotgun_y",(-sin(shotgun_angle)*shotgun_value)*(shotgun_tps*60),shotgun_tps,true,shotgun_deceleration_tps)

func _ready():
	super()
	set_floor_constant_speed_enabled(true)
	set_floor_snap_length(10)
	set_floor_max_angle(0.9)
	shotgun_cd_timer = $ShotgunCd
	$gun/blastTimer.wait_time=shotgun_tps
	type = "player"

func tempoclamp_addon_x():
	if shotgun_instance_x.activated:
			shotgun_instance_x.global_end()
func tempoclamp_addon_y():
	if shotgun_instance_y.activated:
			shotgun_instance_y.global_end()
	if is_jumping:
		is_jumping = false

func process_addon(delta):
	if just_jumping:
		just_jumping = false
	direction = Input.get_axis("left", "right")
	$gun.rotate_gun(position)
	shotgun_dash()

	test()
	velocity.x=shotgun_instance_x.return_value()
	velocity.y=shotgun_instance_y.return_value()
	
	if shotgun_instance_x.activated:
		if has_same_sign(raycastCollisions().x,shotgun_instance_x.value_init) and raycastCollisions().x != 0:
			shotgun_instance_x.global_end()
	if shotgun_instance_y.activated:
		if has_same_sign(raycastCollisions().y,shotgun_instance_y.value_init) and raycastCollisions().y != 0:
			shotgun_instance_y.global_end()
	
	if not shotgun_instance_x.bursting or not shotgun_instance_y.bursting:
		exp_gravity+=gravity * delta
		velocity.y+=exp_gravity
		if shotgun_instance_x.decelerating :
			if has_same_sign(direction,shotgun_instance_x.value_counter) and abs(shotgun_instance_x.value_counter)<=speed and direction!=0 :
				shotgun_instance_x.end_deceleration()
				velocity.x+=walk()
			if not has_same_sign(direction,shotgun_instance_x.value_counter) and direction!=0:
				shotgun_instance_x.end_deceleration()
				velocity.x+=walk()
		else:
			velocity.x+=walk()
			
		if shotgun_instance_y.decelerating:
			pass

	jump()
	if is_jumping:
		if (raycastCollisions().y < 0):
			is_jumping = false
		velocity.y+=jump_velocity
	
	if direction == 0 or not has_same_sign(direction,velocity.x):
		direction = into_sign(velocity.x)

func on_floor_addon():
	exp_gravity = 0
	if not just_jumping:
		is_jumping = false

func not_on_floor_addon():
	pass
func shotgun_dash():
	if Input.is_action_just_pressed("action1") and not is_shotgun_on_cd():
		$gun.blast()
		shotgun_angle =position.angle_to_point(get_global_mouse_position())
		shotgun_instance_x=Regular_value.new("shotgun_x",(-cos(shotgun_angle)*shotgun_value)*(shotgun_tps*60),shotgun_tps,true,shotgun_deceleration_tps)
		shotgun_instance_y=Regular_value.new("shotgun_y",(-sin(shotgun_angle)*shotgun_value)*(shotgun_tps*60),shotgun_tps,true,shotgun_deceleration_tps)
		shotgun_instance_x.start()
		shotgun_instance_y.start()

		exp_gravity=0
		if is_jumping:
			is_jumping=false
		shotgun_cd_timer.start()

func is_shotgun_on_cd():
	return !shotgun_cd_timer.is_stopped()

func walk():
	if direction:
		return direction * speed 
	else:
		return 0

func jump():
	if Input.is_action_just_pressed("up") and is_on_floor():
		is_jumping=true
		just_jumping = true
		
func has_same_sign(f1:float,f2:float):
	return f1<0 and f2<0 or f1>0 and f2>0

func raycastCollisions():
	var final_vec = Vector2(0,0)
	if $wallcheckUp.is_colliding():
		final_vec.y=-1
	if $wallcheckDown.is_colliding():
		final_vec.y=1
	if $wallcheckLeft.is_colliding():
		final_vec.x=-1
	if $wallcheckRight.is_colliding():
		final_vec.x=1
	if $wallcheckDiagUpLeft.is_colliding():
		final_vec.x=-1
		final_vec.y=-1
	if $wallcheckDiagUpRight.is_colliding():
		final_vec.x=1
		final_vec.y=-1
	if $wallcheckDiagDownLeft.is_colliding():
		final_vec.x=-1
		final_vec.y=1
	if $wallcheckDiagDownRight.is_colliding():
		final_vec.x=1
		final_vec.y=1
	return final_vec

func test():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var map = collision.get_collider()
		var collipos = collision.get_position()
		collipos -= collision.get_normal() * 8
		var tile_position = map.local_to_map(collipos)
		var tile = map.get_cell_tile_data(0, tile_position)
		if tile != null:
			if tile.get_custom_data("dangerous"):
				pass
				emit_signal("hit")

func _on_hit():
	shotgun_instance_x.global_end()
	shotgun_instance_y.global_end()
	velocity=Vector2(0,0)
	position = spawn_point
