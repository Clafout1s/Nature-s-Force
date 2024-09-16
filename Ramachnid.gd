extends CharacterBody2D

const speed = 300
var state = "idle"
var sprites_in_use = {"base":null,"armL":null,"armR":null,"canon":null}
var body_parts_dict={}
var timer_count=[0,0]
var action = ""
var last_action = ""
var action_ended = true
func _ready():
	body_parts_dict = {"base":[$base1,$base2,$base3],"armL":[$arm1L,$arm2L,$arm3L,$arm4L,$arm5L,$arm6L,$arm7L],"armR":[$arm1R,$arm2R,$arm3R,$arm4R,$arm5R,$arm6R,$arm7R],"canon":[$canon1,$canon2,$canon3]}
	switch_sprite("base",$base1)
	switch_sprite("armL",$arm1L)
	switch_sprite("armR",$arm1R)
	switch_sprite("canon",$canon1)
	
	
func _physics_process(delta):
	chose_behavior()
	act_behavior()
	apply_action()
	move_and_slide()

func chose_behavior():
	if state == "idle":
		if Input.is_action_just_pressed("debug"):
			switch_state("close_attack")

func act_behavior():
	match state:
		"idle":
			idle_behavior()
		"close_attack":
			var rng=RandomNumberGenerator.new()
			var random = rng.randi_range(1,100)
			if random<80 and last_action != "blade_attack":
				switch_action("blade_attack")
			else:
				switch_action("wait")

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

func idle_behavior():
	switch_sprite("armL",$arm1L)

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
	print(timer_count)
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

func jump_attack():
	pass

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

func switch_action(act):
	if action == "":
		action = act

func end_action():
	reset_timer_count()
	last_action = action
	action = ""
