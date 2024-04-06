
extends CharacterBody2D
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca

@export var SPEED = 250.0
@export var GRAVITY=1500
@export var JUMP_VELOCITY = -500.0
@export var SHOTGUN_VELOCITY = SPEED*8

var movement_list_x=[]
var movement_list_y=[]
var shotgun_activator=false
var shotgun_value=0
var dash_activator = false
var gun_centre_ecart
var down_velocity_modifier=20
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = GRAVITY #ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	gun_centre_ecart=Vector2(position.x-$gun.global_position.x,position.x-$gun.global_position.x)
	
func _physics_process(delta):
	"""
	velocity=Vector2(-cos(angle), -sin(angle))*actual_shot_velocity
	var angle=position.angle_to_point(get_global_mouse_position())
	if Input.is_action_just_pressed("down") and not is_on_floor():
	"""
	rotate_gun()
	var x_modifier = 0
	var y_modifier = 0
	dash_input()
	var to_apply_x=return_apply_regular_burst(movement_list_x)
	var to_apply_y=return_apply_regular_burst(movement_list_y)
	
	x_modifier+=return_horizontal_input()
	y_modifier+=return_jump_input()
	for elex in to_apply_x:
		x_modifier+=elex
	for eley in to_apply_x:
		x_modifier+=eley
	apply_vertical_velocity(delta,y_modifier)
	apply_horizontal_velocity(delta,x_modifier)
	move_and_slide()

func apply_horizontal_velocity(delta, modifier):
	velocity.x =modifier
	if modifier ==0 and movement_list_x==[]:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
func apply_vertical_velocity(delta,modifier=1):
	if not is_on_floor():
		velocity.y += gravity * delta + modifier
	elif modifier<0:
		velocity.y+=modifier
		
func return_horizontal_input():
	var direction = Input.get_axis("left", "right")
	if direction:
		return direction * SPEED 
	else:
		return 0
		
func return_jump_input():
	if Input.is_action_just_pressed("up") and is_on_floor():
		return JUMP_VELOCITY
	else:
		return 0

func dash_input():
	if Input.is_action_just_pressed("action_bar"):
		var direction = Input.get_axis("left", "right")
		if direction:
			regular_burst_launch("dash",direction*100,dash_activator,20,movement_list_x)
	return 0

func regular_burst_launch(id,value,activator:bool,frame_start,movement_list:Array):
	if not activator and find_in_list(movement_list,id)==null:
		movement_list.append([id,frame_start,value])
		activator=true
		
func return_apply_regular_burst(movement_list):
	print(movement_list)
	var final_list=[]
	for ele in movement_list:
		var value = ele[2]
		var frames=ele[1]
		if frames==0:
			movement_list.erase(ele)
		else:
			ele[1]-=1
			final_list.append(value)
	return final_list
	
func find_in_list(list,thing):
	for ele in list:
		if thing in ele:
			return ele
	return null
"""
func apply_shotgun_physics():
	if Input.is_action_just_pressed("action2"):
		shotgun_shot=true
		actual_shot_velocity=SHOTGUN_VELOCITY
	if shotgun_shot:
		actual_shot_velocity-=shot_percent_reduction/float(100)*float(actual_shot_velocity)
		print(actual_shot_velocity)
		if actual_shot_velocity<=10/float(100)*float(SHOTGUN_VELOCITY):
			shotgun_shot=false
			actual_shot_velocity=0
"""
func has_same_sign(f1:float,f2:float):
	return f1<0 and f2<0 or f1>0 and f2>0

func rotate_gun():
	var angle=position.angle_to_point(get_global_mouse_position())
	$gun.position =Vector2(cos(angle), sin(angle))*gun_centre_ecart
	$gun.look_at(get_global_mouse_position())


"""
Objectif: un systeme de velocité x et y indépendatment des commandes: elles ne sont que des arguments spécifiques du syst
comme le dash

shotgun:  quand c2: on lance shotgun, stocke l'angle
si shotgun: x_modifier + cos mchin truc,  y_modifier + sin machin truc
shotgun speed est réduite tout le long


func apply_shotgun_x(value):
	if shotgun:
		bla bla
		value+=return

func regular_burst(value,activator:bool,timer:(frames or real timer),burst_list):
	if not activator:
		movement_list.append()
	elif frames==0:
		movement_list.pop()
	else:
		(frames-1)
		return value
	return 0
		
"""
		
		
