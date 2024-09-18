extends CharacterBody2D

var character_name = "Ramachnid"
var moving_gravity = 0
signal hit
signal death
var speed = 3000
var frame_speed = 30
var state = "idle"
var sprites_in_use = {"base":null,"armL":null,"armR":null,"canon":null}
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
	body_parts_dict = {"base":[$base1,$base2,$base3],"armL":[$arm1L,$arm2L,$arm3L,$arm4L,$arm5L,$arm6L,$arm7L],"armR":[$arm1R,$arm2R,$arm3R,$arm4R,$arm5R,$arm6R,$arm7R],"canon":[$canon1,$canon2,$canon3]}
	base1collision = [$base1/terrain.shape.size,$base1/terrain.position,$base1/terrain2.shape.size,$base1/terrain2.position]
	base2collision = [$base2/terrain.shape.size,$base2/terrain.position,$base2/terrain2.shape.size,$base2/terrain2.position]
	base3collision = [$base3/terrain.shape.size,$base3/terrain.position,$base3/terrain2.shape.size,$base3/terrain2.position]
	switch_sprite("base",$base1)
	switch_sprite("armL",$arm1L)
	switch_sprite("armR",$arm1R)
	switch_sprite("canon",$canon1)

	
func _physics_process(delta):
	velocity = Vector2(0,0)
	if target != null:
		target_position = target.global_position
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
	state = "distant_combat"
	var range = position.x - target_position.x
	if state == "close_combat":
		if abs(range)>=distant_range:
			switch_state("distant_combat")
	elif state == "distant_combat":
		if abs(range)<distant_range:
			switch_state("close_combat")
	elif state== "blocked":
		pass

func chose_action_by_state():
	var proportion_dict = {}
	var banlist={}
	match state:
		"idle":
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
	if sprites_in_use[part] != new_sprite and (old_sprite == null or old_sprite == sprites_in_use[part]):
		if not sprites_in_use[part]==null:
			hide_sprite(part,sprites_in_use[part])
		show_sprite(part,new_sprite)
		sprites_in_use[part]=new_sprite
		if part == "base":
			change_collision_size(new_sprite)

func show_sprite(part,this_sprite):
	if this_sprite in body_parts_dict[part]:
		this_sprite.visible = true

func hide_sprite(part,this_sprite):
	if this_sprite in body_parts_dict[part]:
		this_sprite.visible = false	
	togle_collisions(false,this_sprite)
	togle_orbs(false)

func blade_attack(facing_left ):
	var time_end = 0
	var ending = false
	match timer_count[0]:
		0:
			time_end=30
			if facing_left:
				switch_sprite("armL",$arm7L)
			else:
				switch_sprite("armR",$arm7R)
		1:
			time_end = 40
			if facing_left:
				switch_sprite("armL",$arm4L)
				togle_collisions(true, $arm4L)
			else:
				switch_sprite("armR",$arm4R)
				togle_collisions(true, $arm4R)
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
			togle_collisions(true,$base1)
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
			togle_collisions(true, $base3)
			switch_sprite("armR",$arm3R)
			if global_position.y >= jump_starting_y or is_on_floor():
				is_not_on_floor_forced = true
				if target_position.y >= global_position.y and abs(global_position.x - target_position.x)<=$terrainCollision.shape.size.x:
					player_stomped()
				timer_count[0]+=1
				timer_count[1]=-1
			velocity.y += -jump_initial_speed
			velocity.x += jump_speed_x* direction
		3:
			time_end = 10
			if timer_count[1] ==0:
				is_not_on_floor_forced = false
			switch_sprite("base",$base2)
			togle_collisions(true, $base2)
			switch_sprite("armL",$arm2L)
			switch_sprite("armR",$arm2R)
		4:
			end_action()
			ending = true
			switch_sprite("base",$base1)
			togle_collisions(true,$base1)
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

func togle_collisions_old(on:bool,node):
	var parent_node
	var child_node
	if node.has_node("Area2D"):
		parent_node = node.get_node("Area2D")
		
	elif node.has_node("StaticBody2D"):
		parent_node = node.get_node("StaticBody2D")
		
	if parent_node != null:
		if parent_node.has_node("CollisionPolygon2D"):
			child_node = parent_node.get_node("CollisionPolygon2D")
		elif parent_node.has_node("CollisionShape2D"):
			child_node = parent_node.get_node("CollisionShape2D")
			
		if child_node != null:
			child_node.set_deferred("disabled",!on)
	
func togle_collisions(on:bool,node):
	for parent_node in node.get_children():
		if parent_node is Area2D or parent_node is StaticBody2D:
			for child_node in parent_node.get_children():
				if child_node is CollisionPolygon2D or child_node is CollisionShape2D:
					child_node.set_deferred("disabled",!on)

func togle_orbs(on:bool):
	togle_collisions(on,$crysUR)
	togle_collisions(on,$crysDL)
	togle_collisions(on,$crysDR)
	togle_collisions(on,$crysUL)

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
	$terrainCollision2.shape.size = new_data[2]
	$terrainCollision2.position = new_data[3]
func player_stomped():
	if target != null:
		#target.position.x+=$terrainCollision.shape.size.x + target.shapeCollision.x
		#target_position.x += 1000
		pass
	target.emit_signal("hit",self)


func _on_area_2d_body_entered(body):
	if body.character_name == "player":
		body.emit_signal("hit",self)


