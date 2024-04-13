
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

var active_burst_x=null
var active_burst_y=null

var burst_list=[]
var deceleration_list=[]
var shotgun_burst_x = Burst_Movement.new("shotgun_x","x",500,12,20) #nid,ndimension,nvalue_init,nframes_init,ndeceleration_speed
var shotgun_burst_y = Burst_Movement.new("shotgun_y","y",-1000,12,20)
func _ready():
	gun_centre_ecart=Vector2(position.x-$gun.global_position.x,position.x-$gun.global_position.x)
	

func _physics_process(delta):
	shotgun()
	rotate_gun()

	exp_gravity+=gravity*delta
	if is_on_floor():
		exp_gravity=0
	
	x_modifier_constant=return_horizontal_input()
	y_modifier_constant=exp_gravity
	
	apply_vertical_velocity()
	apply_horizontal_velocity()
	move_and_slide()
	
func apply_horizontal_velocity():
	if active_burst_x==null:
		for burst_object in deceleration_list:
			if burst_object.is_dimension_x():
				x_modifier_constant+=burst_object.return_decelerate()
				if burst_object.is_deceleration_over():
					burst_object.end_decelerate(deceleration_list)
		velocity.x = x_modifier_constant
		if x_modifier_constant==0:
			velocity.x=move_toward(velocity.x,0,decelereation_constant)
		
	else:
		velocity.x =  active_burst_x.return_burst_movement()
		if active_burst_x.is_decelerating():
			deceleration_list.append(active_burst_x)
			active_burst_x=null
	
func apply_vertical_velocity():
	if active_burst_y==null:
		for burst_object in deceleration_list:
			if not burst_object.is_dimension_x():
				y_modifier_constant+=burst_object.return_decelerate()
				if burst_object.is_deceleration_over():
					burst_object.end_decelerate(deceleration_list)
		velocity.y = y_modifier_constant
		if y_modifier_constant==0:
			velocity.y=move_toward(velocity.y,0,decelereation_constant)
	else:
		velocity.y =  active_burst_y.return_burst_movement()
		if active_burst_y.is_decelerating():
			deceleration_list.append(active_burst_y)
			active_burst_y=null

func shotgun():
	if Input.is_action_just_pressed("action2") and shotgun_burst_x not in deceleration_list and shotgun_burst_y not in deceleration_list:
		
		active_burst_x=shotgun_burst_x
		active_burst_y=shotgun_burst_y
		active_burst_x.activate()
		active_burst_y.activate()
		print(active_burst_x.to_string())
func return_horizontal_input():
	var direction = Input.get_axis("left", "right")
	if direction:
		return direction * SPEED 
	else:
		return 0
		
func jump_input():
	if Input.is_action_just_pressed("up") and is_on_floor():
		pass

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
	func _init(nid,ndimension,nvalue_init,nframes_init,ndeceleration_speed):
		self.id=nid
		self.dimension=ndimension
		value_init=nvalue_init
		value=value_init
		frames_init=nframes_init
		frames=frames_init
		deceleration_speed=ndeceleration_speed
		active=false
		decelerate=false
	func _to_string():
		print(id," ",dimension," ",active," ",decelerate," ",value," ",frames," ",deceleration_speed," ")
	func is_dimension_x():
		return dimension=="x"
	
	func return_burst_movement():
		if active:
			print(frames)
			frames-=1
			deactivate_if_finished()
			return value
		else:
			return 0
	func activate():
		frames=frames_init
		active=true
		value=value_init
	func deactivate():
		active=false
		frames=frames_init
	func is_activated():
		return activate
	func deactivate_if_finished():
		if frames==0:
			deactivate()
			decelerate=true
		elif frames <0:
			print("frame countdonwn error")
		
	func start_decelerate(list):
		list.append(self)
	func is_decelerating():
		return decelerate
	func return_decelerate():
		if decelerate:
			value=move_toward(value,0,deceleration_speed)
			return value
	func is_deceleration_over():
		if decelerate:
			return value==0
		else:
			return "not started dingus"
	func end_decelerate(list):
		list.remove_at(list.find(self))
		decelerate=false
		
