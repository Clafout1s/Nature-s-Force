
extends CharacterBody2D
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca

@export var SPEED = 250.0
@export var GRAVITY=1500
@export var JUMP_VELOCITY = -500.0
@export var SHOTGUN_VELOCITY = 1000


var movement_list_x=[]
var movement_list_y=[]
var shotgun_activator=false
var shotgun_value=0
var dash_activator = false
var gun_centre_ecart
var down_velocity_modifier=20
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = GRAVITY #ProjectSettings.get_setting("physics/2d/default_gravity")
var exp_gravity=0

var x_modifier_burst = 0
var x_modifier_constant=0
var y_modifier_burst = 0
var y_modifier_constant=0

var jump_activator
	
func _ready():
	gun_centre_ecart=Vector2(position.x-$gun.global_position.x,position.x-$gun.global_position.x)
	
func _physics_process(delta):
	
	jump_input()
	rotate_gun()
	shotgun_input()
	#dash_input()
	
	exp_gravity+=gravity*delta
	if is_on_floor():
		exp_gravity=0
	
	var to_apply_x=return_apply_regular_burst(movement_list_x)
	var to_apply_y=return_apply_regular_burst(movement_list_y)
	
	x_modifier_constant=return_horizontal_input()
	x_modifier_burst=burst_test_input()
	y_modifier_burst=0
	y_modifier_constant=exp_gravity
	if jump_activator:
		y_modifier_constant+=JUMP_VELOCITY
	
	for elex in to_apply_x:
		x_modifier_burst+=elex
	for eley in to_apply_y:
		y_modifier_burst+=eley
	
	print(x_modifier_burst," ",y_modifier_burst)
	apply_vertical_velocity(delta,y_modifier_constant,y_modifier_burst)
	apply_horizontal_velocity(delta,x_modifier_constant,x_modifier_burst)
	move_and_slide()
	if is_on_floor():
		#print("in")
		y_modifier_burst = 0
		jump_activator=false
	
	
func apply_horizontal_velocity(delta,modifier_constant, modifier_burst):
	velocity.x = modifier_constant + modifier_burst
	velocity.x = move_toward(velocity.x, modifier_constant, abs(SPEED))
	
func apply_vertical_velocity(delta,modifier_constant, modifier_burst):
	if modifier_burst==0:
		velocity.y = modifier_constant
	else:
		velocity.y =modifier_burst
	#y_modifier_burst=move_toward(y_modifier_burst, 0, abs(SPEED*50/float(100)))
	
	#print(velocity.y)
	
	#print(velocity.y)
	#y_modifier_burst=0

		
func return_horizontal_input():
	var direction = Input.get_axis("left", "right")
	if direction:
		return direction * SPEED 
	else:
		return 0
		
func jump_input():
	if Input.is_action_just_pressed("up") and is_on_floor():
		jump_activator=true

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
		regular_burst_launch("shotgun_x",-cos(angle)*SHOTGUN_VELOCITY,shotgun_activator,10,movement_list_x)
		regular_burst_launch("shotgun_y",-sin(angle)*SHOTGUN_VELOCITY,shotgun_activator,10,movement_list_y)
		
func burst_test_input():
	if Input.is_action_just_pressed("action_bar"):
		var direction = Input.get_axis("left", "right")
		return direction*1000
	else:
		return 0

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
		
		
