
extends Character_basics
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca
var jump_height=110.0
var jump_time=0.35
var jump_velocity= -(2.0 * jump_height) / jump_time
var just_jumping = false
var is_jumping=false
var shotgun_value = 7000
var shotgun_angle=0
var shotgun_burst_frames=5
var shotgun_deceleration_movement = 15000
var shotgun_deceleration_frames=20
var shotgun_cd_timer
var shotgun_slots_init = 2
var shotgun_slots
var shotgun_slots_UI
var shotgun_slots_UI_instance = preload("res://bulletSlotsUI.tscn").instantiate()
var shotgun_instance_x=Regular_value.new("shotgun_x",(-cos(shotgun_angle)*shotgun_value),shotgun_burst_frames,true,shotgun_deceleration_movement*direction,shotgun_deceleration_frames)
var shotgun_instance_y=Regular_value.new("shotgun_y",(-sin(shotgun_angle)*shotgun_value),shotgun_burst_frames,true,shotgun_deceleration_movement*direction,shotgun_deceleration_frames)
var sword_instance = preload("res://laser_sword.tscn").instantiate()

var invuln_frames_start = 180
var invuln_frames = 0
var invuln_gravity = 50
var invuln = false
var invuln_direction
var invuln_begin_speed = Vector2(650,350)
var  collision_mask_list = []
var boss_hp = 5
var lifebar
func _ready():
	character_name = "player"
	super()
	speed = 500
	set_floor_constant_speed_enabled(true)
	set_floor_snap_length(10)
	set_floor_max_angle(0.9)
	$gun/blastTimer.wait_time=2*shotgun_burst_frames/float(60)
	$gun.user = self
	shotgun_cd_timer = $ShotgunCd
	type = "player"
	shotgun_slots = shotgun_slots_init
	root_node.add_child(shotgun_slots_UI_instance)
	shotgun_slots_UI = shotgun_slots_UI_instance
	add_child(sword_instance)
	nodeCollision = $CollisionShape2D
	nodeSprite = $mainCharac
	adaptShape()
	if hp>1:
		root_node.add_ui("lifebar",[hp,self])
	
func tempoclamp_addon_x():
	if shotgun_instance_x.activated:
			end_shotgun_blast(true,false)
func tempoclamp_addon_y():
	if shotgun_instance_y.activated:
			end_shotgun_blast(false,true)
	if is_jumping:
		is_jumping = false

func process_addon(delta):
	if invuln:
		during_invuln()
	else: 
		detect_terrain_effect(self)
		if just_jumping:
			just_jumping = false
		direction = Input.get_axis("left", "right")
		$gun.rotate_gun(position)
		shotgun_dash()
		sword_attack()
		
		velocity.x=shotgun_instance_x.return_value()
		velocity.y=shotgun_instance_y.return_value()
		
		if shotgun_instance_x.activated:
			if has_same_sign(raycastCollisions().x,shotgun_instance_x.value_init) and raycastCollisions().x != 0:
				end_shotgun_blast(true,false)
		if shotgun_instance_y.activated:
			if has_same_sign(raycastCollisions().y,shotgun_instance_y.value_init) and raycastCollisions().y != 0:
				end_shotgun_blast(false,true)
		
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
		
		if not has_same_sign(direction,nodeSprite.scale.x) and direction != 0:
			swap()
		if shotgun_instance_x.just_finished or shotgun_instance_y.just_finished:
			end_shotgun_blast(false,false,true)
		
func swap():
	nodeSprite.scale.x *= -1
	nodeCollision.scale.x *= -1
	$hurt.scale.x *= -1

func on_floor_addon():
	exp_gravity = 0
	if not just_jumping:
		is_jumping = false
	if not shotgun_instance_x.activated and not shotgun_instance_y.activated:
		reset_shotgun_slots()

func not_on_floor_addon():
	pass
func shotgun_dash():
	if Input.is_action_just_pressed("action1") and not is_shotgun_on_cd() and not shotgun_slots <= 0:
		$gun.end_blast()
		$gun.blast(position)
		shotgun_slots-=1
		shotgun_slots_UI.switch_to_empty_shell()
		shotgun_angle =position.angle_to_point(get_global_mouse_position())
		shotgun_instance_x=Regular_value.new("shotgun_x",(-cos(shotgun_angle)*shotgun_value),shotgun_burst_frames,true,shotgun_deceleration_movement*-cos(shotgun_angle),shotgun_deceleration_frames)
		shotgun_instance_y=Regular_value.new("shotgun_y",(-sin(shotgun_angle)*shotgun_value),shotgun_burst_frames,true,shotgun_deceleration_movement*-sin(shotgun_angle),shotgun_deceleration_frames)
		shotgun_instance_x.start()
		shotgun_instance_y.start()

		exp_gravity=0
		if is_jumping:
			is_jumping=false
		shotgun_cd_timer.start()

func sword_attack():
	if Input.is_action_just_pressed("action2"):
		sword_instance.start_slash(global_position)
		sword_instance.user = self
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

func reset_shotgun_slots():
	for i in range(shotgun_slots_init-shotgun_slots):
		shotgun_slots_UI.switch_to_plain_shell()
	shotgun_slots = shotgun_slots_init
	
func _on_death():
	"""
	end_shotgun_blast(true,true)
	velocity=Vector2(0,0)
	position = spawn_point
	hp=1
	"""
	root_node.reset_level()

func end_shotgun_natural():
	end_shotgun_blast()

func end_shotgun_blast(x=false,y=false,end_blast=false):
	if end_blast:
		pass
		#$gun.end_blast()
	if x:
		shotgun_instance_x.global_end()
	if y:
		shotgun_instance_y.global_end()
	
func dangerous_terrain_behavior(body):
	body.emit_signal("hit")


func _on_tree_exiting():
	shotgun_cd_timer.stop()
	shotgun_slots_UI_instance.queue_free()
	root_node.remove_child.call_deferred(shotgun_slots_UI)
	
func start_invuln():
	$hurt.visible = true
	invuln = true
	end_shotgun_blast(true,true)
	velocity=Vector2(0,0)
	exp_gravity = 0
	for i in range(8):
		collision_mask_list.append(get_collision_mask_value(i+1))
		if i != 0:
			set_collision_mask_value(i+1,false)
	
func end_invuln():
	$hurt.visible = false
	invuln = false
	invuln_frames = 0
	velocity = Vector2(0,0)
	
	for i in range(8):
		set_collision_mask_value(i+1,collision_mask_list[i])
func during_invuln():
	exp_gravity+= invuln_gravity
	invuln_frames += 1
	
	velocity.x = invuln_begin_speed.x * invuln_direction
	velocity.y = -invuln_begin_speed.y
	
	velocity.y += exp_gravity
	if is_on_floor() and not invuln_frames==1 or invuln_frames == invuln_frames_start:
		end_invuln()

func _on_hit(_hitter=null,_type="other"):
	var direction = 0
	if not hp -1 <=0:
		if _hitter != null:
			invuln_direction = into_sign(global_position.x-_hitter.global_position.x)
			if invuln_direction == 0:
				invuln_direction = 1
			if not invuln:
				hp-=1
				start_invuln()
				update_lifebar()
			
	else:
		update_lifebar()
		hp-=1
		
func update_lifebar():
	if not lifebar==null:
		lifebar.get_node("ProgressBar").value-=1
