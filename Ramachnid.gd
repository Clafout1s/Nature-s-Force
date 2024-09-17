extends CharacterBody2D

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
var jump_initial_speed = 500
var jump_speed_x = 400
var jump_starting_y
var jump_starting_x

func _ready():
	body_parts_dict = {"base":[$base1,$base2,$base3],"armL":[$arm1L,$arm2L,$arm3L,$arm4L,$arm5L,$arm6L,$arm7L],"armR":[$arm1R,$arm2R,$arm3R,$arm4R,$arm5R,$arm6R,$arm7R],"canon":[$canon1,$canon2,$canon3]}
	switch_sprite("base",$base1)
	switch_sprite("armL",$arm1L)
	switch_sprite("armR",$arm1R)
	switch_sprite("canon",$canon1)
func _physics_process(delta):
	if Input.is_action_just_pressed("debug"):
		debug_block = false
	if not debug_block:
		new_jump_action(1)
		
	"""
	chose_state()
	chose_action_by_state()
	apply_action()
	
	"""
	move_and_slide()

func chose_state():
	state = "close_combat"
	
	if state == "close_combat":
		pass
	elif state == "far_combat":
		pass
	elif state== "blocked":
		pass

func chose_action_by_state():
	var proportion_dict = {}
	var banlist={}
	match state:
		"idle":
			proportion_dict = {"wait":100}
		"close_combat":
			var range = 100
			var close_range = 50
			var distant_range = 1000
			
			if range<=close_range:
				proportion_dict = {"blade_attack":70,"jump r":10,"walk r":10,"wait":10}
				banlist = {"blade_attack":last_action=="blade_attack","jump r":last_action=="jump r"}
			elif close_range<range and range<distant_range:
				proportion_dict = {"walk l":60,"jump l":20,"blade_attack":10,"walk r":10}
				banlist = {"blade_attack":last_action=="blade_attack","jump l":last_action=="jump l"}
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

func show_sprite(part,this_sprite):
	if this_sprite in body_parts_dict[part]:
		this_sprite.visible = true

func hide_sprite(part,this_sprite):
	if this_sprite in body_parts_dict[part]:
		this_sprite.visible = false	

func blade_attack():
	var time_end = 0
	var ending = false
	match timer_count[0]:
		0:
			time_end = 60
			switch_sprite("armL",$arm4L)
		1:	
			switch_sprite("armL",$arm1L)
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
			blade_attack()
		"wait":
			wait_action()
		"walk l":
			walk_action(-1)
		"walk r":
			walk_action(1)
		"switch distant":
			end_action()
			switch_state("distant")
		_:
			wait_action()

func switch_action(act):
	if action == "":
		action = act

func end_action():
	reset_timer_count()
	last_action = action
	action = ""

func new_jump_action(direction):
	if timer_count==[0,0]:
		jump_starting_y = position.y
		jump_starting_x = position.x
		timer_count[0]+=1
		velocity.y = -jump_initial_speed 
		velocity.x = jump_speed_x* direction
	elif position.y >= jump_starting_y and timer_count[1]!=0:
		print(timer_count)
		print(jump_starting_x - position.x)
		end_action()
		debug_block = true
		velocity=Vector2(0,0)
	else:
		timer_count[1]+=1
		print(velocity.x)
		velocity.y += jump_gravity

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
	
			
