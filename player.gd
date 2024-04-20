
extends CharacterBody2D
#en outre j'aime beaucoup mon papa qui est le meilleur papa du monde et qui fait caca

@export var SPEED = 250.0
@export var GRAVITY=1500
@export var JUMP_VELOCITY = -500.0
@export var SHOTGUN_VELOCITY = 1000

var gun_centre_ecart
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = GRAVITY #ProjectSettings.get_setting("physics/2d/default_gravity")
var exp_gravity=0
var decelereation_constant=20
var x_modifier_constant=0
var y_modifier_constant=0

var active_burst_x=[]
var active_burst_y=[]

var burst_list=[]
var deceleration_list=[]

var jump_value=0

 #nid,ndimension,nvalue_init,nframes_init,ndeceleration_speed
func _ready():
	gun_centre_ecart=Vector2(position.x-$gun.global_position.x,position.x-$gun.global_position.x)
	
func _physics_process(delta):
	shotgun()
	rotate_gun()
	jump_input()
	
	
	x_modifier_constant=return_horizontal_input()
	y_modifier_constant=exp_gravity
	
	apply_vertical_velocity(delta)
	apply_horizontal_velocity()
	move_and_slide()
	
func apply_horizontal_velocity():
	if active_burst_x==[]:
		for burst_object in deceleration_list:
			if burst_object.is_dimension_x():
				x_modifier_constant+=burst_object.return_deceleration()
		velocity.x = x_modifier_constant
		if x_modifier_constant==0:
			velocity.x=move_toward(velocity.x,0,decelereation_constant)
		
	else:
		velocity.x =  active_burst_x[0].return_burst_value()
	
func apply_vertical_velocity(delta):
	if active_burst_y==[]:
		exp_gravity+=gravity*delta
		if is_on_floor():
			exp_gravity=0
		for burst_object in deceleration_list:
			if not burst_object.is_dimension_x():
				y_modifier_constant+=burst_object.return_deceleration()
		velocity.y = y_modifier_constant+jump_value
		if y_modifier_constant==0:
			velocity.y=move_toward(velocity.y,0,decelereation_constant)
	else:
		velocity.y =  active_burst_y[0].return_burst_value()

func shotgun():
	if Input.is_action_just_pressed("action2") and active_burst_x==[] and active_burst_y==[]:
		var angle=position.angle_to_point(get_global_mouse_position())
		var burst_x=Burst_Movement.new("shotgun_x","x",500*-cos(angle),20,2,burst_list,active_burst_x,deceleration_list)
		var burst_y=Burst_Movement.new("shotgun_y","y",500*-sin(angle),20,2,burst_list,active_burst_y,deceleration_list)
		burst_x.activate()
		burst_y.activate()
func return_horizontal_input():
	var direction = Input.get_axis("left", "right")
	if direction:
		return direction * SPEED 
	else:
		return 0
		
func jump_input():
	if Input.is_action_just_pressed("up") and is_on_floor():
		jump_value=-500
	elif is_on_floor():
		jump_value=0
func dash_input():
	if Input.is_action_just_pressed("action_bar"):
		var direction = Input.get_axis("left", "right")
		if direction:
			pass
	return 0
	
func find_in_list(list,thing):
	for ele in list:
		if thing in ele:
			return ele
	return null

func shotgun_input():
	if Input.is_action_just_pressed("action2"):
		var angle=position.angle_to_point(get_global_mouse_position())
		pass
		
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

class Burst_Movement:
	var id
	var dimension
	var active:bool
	var decelerate:bool
	var value_init
	var value
	var frames_init
	var frames
	var deceleration_speed
	var burst_list
	var active_burst_spot
	var deceleration_list
	func _init(nid,ndimension,nvalue_init,nframes_init,ndeceleration_speed,burst_list,nactive_burst_spot,deceleration_list):
		self.id=nid
		self.dimension=ndimension
		value_init=nvalue_init
		value=value_init
		frames_init=nframes_init
		frames=frames_init
		deceleration_speed=ndeceleration_speed
		active=false
		decelerate=false
		self.burst_list=burst_list
		self.burst_list.append(self)
		self.active_burst_spot=nactive_burst_spot
		self.deceleration_list=deceleration_list
		
	func getId():
		return id
	func _to_string():
		print(id," ",dimension," ",active," ",decelerate," ",value," ",frames," ",deceleration_speed," ")
	func is_dimension_x():
		return dimension=="x"
	
	func activate():
		reset_moving_values()
		active_burst_spot.append(self)
		active=true
		decelerate=false
	func deactivate():
		reset_moving_values()
		active=false
		active_burst_spot.remove_at(active_burst_spot.find(self))
		
	func start_deceleration():
		reset_moving_values()
		decelerate=true
		deceleration_list.append(self)
	func end_deceleration():
		reset_moving_values()
		deceleration_list.remove_at(deceleration_list.find(self))
		decelerate=false
	func reset_moving_values():
		frames=frames_init
		value=value_init
	func is_active():
		return active
	func is_decelerate():
		return decelerate
	func return_burst_value():
		if active:
			frames-=1
			if frames==0:
				deactivate()
				start_deceleration()
			return value
		else:
			return 0
	func return_deceleration():
		if decelerate:
			
			value=move_toward(value,0,deceleration_speed)
			print(value)
			if value==0:
				end_deceleration()
			return value
		else:
			return 0
	func give_burst_spot():
		return active_burst_spot
		
