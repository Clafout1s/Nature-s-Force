
extends CharacterBody2D
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca

@export var SPEED = 250.0
@export var GRAVITY=1500
@export var JUMP_VELOCITY = -500.0
@export var SHOTGUN_VELOCITY = SPEED*2


var movement_list_x=[]
var movement_list_y=[]
var shotgun_activator=false
var shotgun_value=0
var dash_activator = false
var gun_centre_ecart
var down_velocity_modifier=20
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = GRAVITY #ProjectSettings.get_setting("physics/2d/default_gravity")


var x_modifier_burst = 0
var x_modifier_constant=0
var y_modifier_burst = 0
var y_modifier_constant=0
	
func _ready():
	gun_centre_ecart=Vector2(position.x-$gun.global_position.x,position.x-$gun.global_position.x)
	
func _physics_process(delta):

	rotate_gun()
	
	
	dash_input()
	shotgun_input()
	
	
	var to_apply_x=return_apply_regular_burst(movement_list_x)
	var to_apply_y=return_apply_regular_burst(movement_list_y)
	
	x_modifier_constant=return_horizontal_input()
	y_modifier_burst+=return_jump_input()
	y_modifier_constant+=gravity*delta
	for elex in to_apply_x:
		x_modifier_burst+=elex
	for eley in to_apply_y:
		y_modifier_burst+=eley
	apply_vertical_velocity(y_modifier_constant,y_modifier_burst)
	apply_horizontal_velocity(x_modifier_constant,x_modifier_burst)
	move_and_slide()

func apply_horizontal_velocity(modifier_constant, modifier_burst):
	velocity.x = modifier_constant + modifier_burst
	
	if modifier_burst == 0:
		velocity.x = move_toward(modifier_constant, 0, SPEED)
	else:
		modifier_burst=0
		print(x_modifier_burst)
	
func apply_vertical_velocity(modifier_constant, modifier_burst):

	velocity.y = modifier_constant + modifier_burst
	if modifier_burst == 0:
		velocity.x = move_toward(modifier_constant, 0, SPEED)
	else:
		modifier_burst=0
		print(x_modifier_burst)
		
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

func shotgun_input():
	if Input.is_action_just_pressed("action2"):
		
		var angle=position.angle_to_point(get_global_mouse_position())
		regular_burst_launch("shotgun_x",-cos(angle)*SHOTGUN_VELOCITY,shotgun_activator,8,movement_list_x)
		regular_burst_launch("shotgun_y",-sin(angle)*SHOTGUN_VELOCITY,shotgun_activator,8,movement_list_y)

	
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
		
		
