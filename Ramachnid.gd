extends CharacterBody2D

var root_node
var character_name = "Ramachnid"
var moving_gravity = 0
signal hit
signal death
var speed = 3000
var frame_speed = 30
var state = "idle"
var sprites_in_use = {"base":null,"armL":null,"armR":null,"canon":null}
var boost_dict = {"blade":1,"canon":1}
var body_parts_dict={}
var timer_count=[0,0]
var action = ""
var last_action = ""
var action_ended = true
var movement_instance_x = null
var movement_instance_y = null
var target
var debug_block = true
var jump_gravity = 30
var jump_initial_speed = 1000
var jump_speed_x = 500
var jump_starting_y
var jump_starting_x
var starting_direction=null
var target_position = Vector2(500,200)
var base1collision 
var base2collision 
var base3collision
var is_not_on_floor_forced = false
var close_range = 200
var distant_range = 1000
func _ready():
	root_node = get_tree().root.get_child(0)
	body_parts_dict = {"base":[$base1,$base2,$base3],"armL":[$arm1L,$arm2L,$arm3L,$arm4L,$arm5L,$arm6L,$arm7L],"armR":[$arm1R,$arm2R,$arm3R,$arm4R,$arm5R,$arm6R,$arm7R],"canon":[$canon1,$canon2,$canon3,$canon4]}
	base1collision = [$base1/terrain.shape.size,$base1/terrain.position]
	base2collision = [$base2/terrain.shape.size,$base2/terrain.position]
	base3collision = [$base3/terrain.shape.size,$base3/terrain.position]
	switch_sprite("base",$base1)
	switch_sprite("armL",$arm1L)
	switch_sprite("armR",$arm1R)
	switch_sprite("canon",$canon1)
	
func _physics_process(delta):
	velocity = Vector2(0,0)
	if target != null:
		target_position = target.global_position
	if not state == "blocking":
		chose_state()
		chose_action_by_state()
		apply_action()
		
	if not is_on_floor():
		moving_gravity+=jump_gravity
		velocity.y+=moving_gravity
	if is_on_floor() and not is_not_on_floor_forced:
		moving_gravity = 0
	move_and_slide()

func chose_state():
	state = "idle"
	var range = position.x - target_position.x
	if state == "close_combat":
		if abs(range)>=distant_range:
			switch_state("distant_combat")
	elif state == "distant_combat":
		if abs(range)<distant_range:
			switch_state("close_combat")

func chose_action_by_state():
	var proportion_dict = {}
	var banlist={}
	match state:
		"idle":
			proportion_dict = {"blade_attack":100}
		"dying":
			proportion_dict = {"wait":100}
		"close_combat":
			var range = position.x - target_position.x
			
			if abs(range)<=close_range:
				proportion_dict = {"blade_attack":50,"jump stay":20,"walk out":25,"wait":5}
				banlist = {"blade_attack":last_action=="blade_attack","jump stay":last_action=="jump stay"}
			elif close_range<abs(range):
				proportion_dict = {"walk in":50,"jump in":35,"blade_attack":10,"walk out":5}
				banlist = {"blade_attack":last_action=="blade_attack","jump in":last_action=="jump in"}
		"distant_combat":
			proportion_dict = {"wait":20,"walk out": 30,"jump out":20,"walk in":20,"jump in":10}
	assert(proportion_dict!={},"Proportion_dict must have at least 1 tuple")
	switch_action(random_oriented_choice(proportion_dict,banlist))
				

func switch_state(new_state:String):
	state = new_state

func switch_sprite(part,new_sprite,old_sprite = null):
	if old_sprite == null:
		old_sprite = sprites_in_use[part]
	var no_switch = false
	if (part == "armL" and sprites_in_use[part] == $arm6L) or (part == "armR" and sprites_in_use[part] == $arm6R):
		no_switch = true
	if part == "canon":
		if (new_sprite == $canon2 and old_sprite == $canon3) or (old_sprite == $canon2 and new_sprite == $canon3):
			new_sprite = $canon4
		if old_sprite == $canon4:
			no_switch = true
		if old_sprite in [$canon2,$canon3] and new_sprite == $canon1:
			no_switch = true
	if not no_switch and sprites_in_use[part] != new_sprite and (old_sprite == null or old_sprite == sprites_in_use[part]):
		if not sprites_in_use[part]==null:
			hide_sprite(part,sprites_in_use[part])
		show_sprite(part,new_sprite)
		sprites_in_use[part]=new_sprite
		

func show_sprite(part,this_sprite):
	if this_sprite in body_parts_dict[part]:
		this_sprite.visible = true
	togle_collisions(true,this_sprite)
	if part == "base":
		change_collision_size(this_sprite)

func hide_sprite(part,this_sprite):
	if this_sprite in body_parts_dict[part]:
		this_sprite.visible = false
	togle_collisions(false,this_sprite)

func blade_attack(facing_left ):
	var letter
	if facing_left:
		letter = "L"
	else:
		letter = "R"
	var time_end = 0
	var ending = false
	match timer_count[0]:
		0:
			time_end=30/float(boost_dict["blade"])
			if facing_left:
				switch_sprite("armL",$arm7L)
			else:
				switch_sprite("armR",$arm7R)
		1:
			time_end = 40
			if facing_left:
				switch_sprite("armL",$arm4L)
			else:
				switch_sprite("armR",$arm4R)
		2:
			if facing_left:
				switch_sprite("armL",$arm1L)
			else:
				switch_sprite("armR",$arm1R)
			end_action()
			ending = true
	if timer_count[1] >= time_end:
		timer_count[0]+=1
		timer_count[1]=-1
	timer_count[1]+=1
	if ending:
		reset_timer_count()

func wait_action():
	var time_end = 0
	var ending = false
	match timer_count[0]:
		0:
			switch_sprite("base",$base1)
			switch_sprite("armL",$arm1L)
			switch_sprite("armR",$arm1R)
			time_end = 60
			
		1:
			end_action()
			ending = true
	if timer_count[1] >= time_end:
		timer_count[0]+=1
		timer_count[1]=-1
	timer_count[1]+=1
	if ending:
		reset_timer_count()

func walk_action(direction):
	var time_end = 0
	var ending = false
	match timer_count[0]:
		0:
			movement_instance_x = Regular_value.new("Ramachnid walk x",speed*direction,frame_speed)
			movement_instance_x.start()
			time_end = 0
		1:
			time_end = frame_speed
			velocity.x = movement_instance_x.return_value()
		2:
			end_action()
			ending = true
	if timer_count[1] >= time_end:
		timer_count[0]+=1
		timer_count[1]=-1
	timer_count[1]+=1
	if ending:
		reset_timer_count()

func canon_attack():
	pass

func reset_timer_count():
	timer_count = [0,0]

func apply_action():
	match action:
		"blade_attack":
			init_starting_direction(target_position.x - position.x)
			var facing_left = true
			if starting_direction==1:
				facing_left = false
			blade_attack(facing_left)
		"wait":
			wait_action()
		"walk in":
			init_starting_direction(target_position.x - position.x)
			walk_action(starting_direction)
		"walk out":
			init_starting_direction(position.x-target_position.x)
			walk_action(starting_direction)
		"switch distant":
			end_action()
			switch_state("distant")
		"jump in":
			init_starting_direction(target_position.x - position.x)
			new_jump_action(starting_direction)
		"jump out":
			init_starting_direction(position.x-target_position.x)
			new_jump_action(starting_direction)
		"jump stay":
			new_jump_action(0)
		_:
			wait_action()

func init_starting_direction(value):
	if starting_direction == null:
		starting_direction = into_sign(value)

func switch_action(act):
	if action == "":
		action = act

func end_action():
	reset_timer_count()
	last_action = action
	action = ""
	starting_direction = null

func new_jump_action(direction):
	assert(direction in [1,0,-1],"direction is either 0, 1 or -1")
	var time_end = 0
	var ending = false
	match timer_count[0]:
		0:
			time_end = 20
			switch_sprite("base",$base2)
			togle_specific_collision(false,$base2/stomp/CollisionShape2D)
			switch_sprite("armL",$arm2L)
			switch_sprite("armR",$arm2R)
		1:
			time_end = 0
			jump_starting_y = position.y
			jump_starting_x = position.x
			velocity.y += -jump_initial_speed 
			velocity.x += jump_speed_x* direction
		2:
			time_end = 120 #big value, not used
			switch_sprite("base",$base3)
			switch_sprite("armL",$arm3L)
			switch_sprite("armR",$arm3R)
			if global_position.y >= jump_starting_y or is_on_floor():
				is_not_on_floor_forced = true
				"""
				if target_position.y >= global_position.y and abs(global_position.x - target_position.x)<=$terrainCollision.shape.size.x:
					player_stomped()
				"""
				timer_count[0]+=1
				timer_count[1]=-1
			velocity.y += -jump_initial_speed
			velocity.x += jump_speed_x* direction
		3:
			time_end = 10
			if timer_count[1] ==0:
				is_not_on_floor_forced = false
			switch_sprite("base",$base2)
			switch_sprite("armL",$arm2L)
			switch_sprite("armR",$arm2R)
		4:
			end_action()
			ending = true
			switch_sprite("base",$base1)
			switch_sprite("armL",$arm1L)
			switch_sprite("armR",$arm1R)
	if timer_count[1] >= time_end:
		timer_count[0]+=1
		timer_count[1]=-1
	timer_count[1]+=1
	if ending:
		reset_timer_count()

func random_oriented_choice(options_dict,bandict={} ):
	assert (options_dict !={}, "options_dict must not be empty")
	for option in bandict.keys():
		if bandict[option]:
			options_dict.erase(option)
	var added=0
	var last_option
	for option in options_dict:
		options_dict[option]+=added
		added = options_dict[option]
		last_option = option
	var return_value = last_option
	var random = RandomNumberGenerator.new().randi_range(1,options_dict[last_option])
	var tested_option
	for option in options_dict.keys():
		tested_option = options_dict[option]
		if tested_option >= random and tested_option < options_dict[return_value]:
			return_value = option
	return return_value


func into_sign(f1:float):
	f1 = int(f1)
	if f1<0:
		return -1
	elif f1>0:
		return 1
	else:
		return 0
	
func togle_collisions(on:bool,node):
	var parent_node_banlist = []
	for parent_node in node.get_children():
		if (parent_node is Area2D or parent_node is StaticBody2D) and parent_node not in parent_node_banlist:
			for child_node in parent_node.get_children():
				if child_node is CollisionPolygon2D or child_node is CollisionShape2D:
					if not child_node.disabled == !on:
						child_node.set_deferred("disabled",!on)

func togle_specific_collision(on:bool,collision_node):
	collision_node.set_deferred("disabled",!on)

func togle_orbs(on:bool):
	togle_collisions(on,$crysUR)
	togle_collisions(on,$crysDL)
	togle_collisions(on,$crysDR)
	togle_collisions(on,$crysUL)

func togle_top_orbs(on:bool):
	togle_collisions(on,$crysUR)
	togle_collisions(on,$crysUL)

func togle_bot_orbs(on:bool):
	togle_collisions(on,$crysDL)
	togle_collisions(on,$crysDR)

func change_collision_size(node):
	var old_shape=$terrainCollision.shape.size
	var new_data
	if node == $base1:
		new_data = base1collision
	elif node == $base2:
		new_data = base2collision
	elif node == $base3:
		new_data = base3collision
		
	$terrainCollision.shape.size = new_data[0]
	$terrainCollision.position = new_data[1]
func player_stomped():
	if target != null:
		target.emit_signal("hit",self)


func _on_area_2d_body_entered(body):
	if body.character_name == "player":
		body.emit_signal("hit",self)


func _on_crystal_hit(area,crystal):
	if area.attack_name == "laser_blade":
		if state == "blocking":
			print("in")
			$brokenOrb.start()
			$armBlock.stop()
		match crystal:
			"UR":
				$crysUR.visible = false
				$crysUR/Area2D.disconnect("area_entered",_on_crystal_hit)
				switch_sprite("canon",$canon3)
			"UL":
				$crysUL.visible = false
				$crysUL/Area2D.disconnect("area_entered",_on_crystal_hit)
				switch_sprite("canon",$canon2)
			"DR":
				$crysDR.visible = false
				$crysDR/Area2D.disconnect("area_entered",_on_crystal_hit)
				switch_sprite("armR",$arm6R)
				boost_dict["blade"]+=1
			"DL":
				$crysDL.visible = false
				$crysDL/Area2D.disconnect("area_entered",_on_crystal_hit)
				switch_sprite("armL",$arm6L)
				boost_dict["blade"]+=1
		if ! (true in [$crysUR.visible,$crysUL.visible,$crysDR.visible,$crysDL.visible]):
			begin_end()

func begin_end():
	$crysCENTER.visible = false
	$deathTimer.start()
	state = "dying"
	end_action()

func _on_death_timer_timeout():
	emit_signal("death")

func _on_death():
	root_node.remove_child(self)
	

func _on_area_2d_area_entered(area,side):
	if area.attack_name == "laser_blade":
		switch_sprite("arm"+side,get_node("arm5"+side))
		start_blocking()

func start_blocking():
	$armBlock.start()
	switch_state("blocking")
	end_action()
	reset_timer_count()

func end_blocking():
	var side
	
	if sprites_in_use["armL"] == $arm5L:
		side = "L"
	elif sprites_in_use["armR"] == $arm5R:
		side = "R"
	if side != null:
		switch_sprite("arm"+side,get_node("arm1"+side))
	switch_state("distant_combat")


func _on_arm_block_timeout():
	print("natural timeout")
	end_blocking()


func _on_broken_orb_timeout():
	end_blocking()
