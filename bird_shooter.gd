extends Ennemy_basics

var limit_distance = 1000
var bullet_instance = preload("res://bulletAttack.tscn").instantiate()
var reloading = false
var stunned = false
var target_in_sight = false
var rng = RandomNumberGenerator.new()
var moving = false
var movement_x = Regular_value.new("birbx",0,0)
var movement_y = Regular_value.new("birby",0,0)
var movement_frames = 50
var flee_frames = movement_frames / 3
var favorite_directions=[1]

func _ready():
	super()
	nodeCollision = $CollisionShape2D
	nodeSprite = $Sprite2D
	speed = 5000
	gravity = 0
	direction = -1
	shapeRotated = true
	adaptShape()

func analyse_and_switch():
	if moving == true and not movement_x.activated and not movement_y.activated:
		moving = false
	"""
	if state == "idle":
		if raycast_to_target():
			switch_to_attack()
		if moving == true and not movement_x.activated and not movement_y.activated:
			moving = false
	if state == "attack":
		if not raycast_to_target() and not target_in_sight:
			switch_to_idle()
	"""
func process_addon(delta):
	
	velocity.x = movement_x.return_value()
	velocity.y = movement_y.return_value()
	analyse_and_switch()
	chose_behavior()

func idle_behavior():
	if not moving:
		var test = angle_by_cadran(1)
		start_moving(calculate_movement_angle_RANDOM(120),speed,movement_frames)

func attack_behavior():
	switch_to_idle()
	"""
	var distance = sqrt((target_body.position.x**2)+(target_body.position.y**2))
	if  distance < limit_distance:
		#switch_to_flee()
		pass
	else:
		shoot(target_body)
	
	if not has_same_sign(global_position.x  - target_body.global_position.x, direction):
		swap()
	if not bullet_instance.shooting and not reloading and not stunned and raycast_to_target():
		shoot(target_body)
	"""
func find_behavior():
	pass

func flee_behavior():
	if not moving:
		start_moving(calculate_movement_angle_BY_TARGET(target_body.position,false,120),speed,flee_frames)

func _on_vision_body_entered(body):
	switch_to_flee()
	target_body = body
	target_in_sight = true

func _on_vision_body_exited(body):
	target_in_sight = false
	switch_to_idle()

func shoot(target):
	add_child(bullet_instance)
	bullet_instance.global_position = global_position + Vector2(shapeCollision.x * direction,0)
	bullet_instance.angle = global_position.angle_to_point(target.global_position)
	bullet_instance.add_to_black_list(self)
	bullet_instance.launch()
	bullet_instance.hit_something.connect(_on_hit_something)
	bullet_instance.ending_bullet.connect(_on_bullet_end)

func _on_bullet_end():
	reloading = true
	$reloadTimer.start()
	
func _on_hit_something(body):
	if not body is TileMap:
		body.emit_signal("hit")

func _on_reload_timer_timeout():
	reloading = false

func _on_hit(hitter = null):
	stunned = true
	queue_free()

func _on_damage_zone_body_entered(body):
	body.emit_signal("hit",self)

func calculate_movement_angle(wall_limit_range=0):
	for i in favorite_directions:
		var test_angle = angle_by_cadran(i)
		if not is_wall_detected(test_angle,wall_limit_range):
			var index_i = favorite_directions.find(i)
			if index_i != len(favorite_directions)-1:
				favorite_directions = remove_from_list_to_index(favorite_directions,index_i)
			return test_angle
	var cadran_list = [0,1,2,3]
	var last_option = null
	for i in favorite_directions:
		cadran_list.erase(i)
	cadran_list.shuffle()
	if favorite_directions != []:
		last_option=favorite_directions[0]
		for i in cadran_list.duplicate():
			var ordered_cadran_dict = {0:[1,3],1:[0,2],2:[1,3],3:[2,0]}
			var number = favorite_directions.back()
			if i in ordered_cadran_dict[number]:
				cadran_list.insert(0,i)
	for i in cadran_list:
		if not is_wall_detected(i*PI/2,wall_limit_range):
			favorite_directions.append(i)
			return angle_by_cadran(i)
		if cadran_list.find(i)==0 and last_option == null:
			last_option = i
	return angle_by_cadran(last_option)

func calculate_movement_angle_RANDOM(wall_limit_range=0):
	favorite_directions = []
	return calculate_movement_angle(wall_limit_range)

func calculate_movement_angle_BY_TARGET(target_position:Vector2,closing_in=true,wall_limit_range=0):
	var direction_cadran
	if not closing_in:
		direction_cadran = Vector2(into_sign(global_position.x - target_position.x) , into_sign(global_position.y - target_position.y)) 
	else:
		direction_cadran = Vector2(into_sign(target_position.x - global_position.x) , into_sign(target_position.y - global_position.y)) 
	if abs(global_position.x - target_body.position.x) > abs(global_position.y - target_body.position.y):
		direction_cadran.y = 0
	else:
		direction_cadran.x = 0
	var chosen_cadran = convert_vector_to_cadran(direction_cadran)
	if chosen_cadran not in favorite_directions:
		favorite_directions.pop_at(0)
		favorite_directions.insert(0,chosen_cadran)
	var tempo = calculate_movement_angle(wall_limit_range)
	return tempo

func remove_from_list_to_index(list,index):
	var final_list = []
	var i = 0
	while i <= index:
		final_list.append(list[i])
		i+=1
	return final_list

func angle_by_cadran(cadran_number):
	return cadran_number * PI/2 + rng.randf_range(-PI/6,PI/6)

func is_wall_detected(chosen_angle,wall_limit_range):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position+Vector2(cos(chosen_angle)*wall_limit_range,-sin(chosen_angle)*wall_limit_range))
	var result = space_state.intersect_ray(query)
	return result != {} and result["collider"] is TileMap
			
"""
func calculate_movement_angle(cadran_number=null,banned_cadrans=[],wall_detection=false,wall_limit_range=0):
	var good_angle_found = false
	var tempo_angle
	var cadran_list = [0,1,2,3]
	var space_state = get_world_2d().direct_space_state
	var query
	var result
	for cadran in banned_cadrans:
		cadran_list.erase(cadran)
	if cadran_number == null:
		cadran_number = cadran_list[rng.randi_range(0,len(cadran_list)-1)]
	while not good_angle_found and len(cadran_list)>0:
		cadran_list.erase(cadran_number)
		tempo_angle = (cadran_number * PI/2 + rng.randf_range(-PI/4,PI/4))
		if wall_detection:
			query = PhysicsRayQueryParameters2D.create(global_position, global_position+Vector2(cos(tempo_angle)*wall_limit_range,sin(tempo_angle)*wall_limit_range))
			result = space_state.intersect_ray(query)
			if result != {} and result["collider"] is TileMap:
				cadran_number = cadran_list[rng.randi_range(0,len(cadran_list)-1)]
			else:
				good_angle_found = true
		if not wall_detection:
			good_angle_found = true
	return tempo_angle
"""
"""
func calculate_movement_angle(cadran_number=null,wall_limit_range=0,wall_detection=true,banned_cadran=[]):
	
	Calculate the angle of the bird movement at a random but can be oriented.
	It uses a 4-sided-cadran to do so, going:
	 0-rightish, 1-upish, 2-leftish, 3-downish, ish being that these are general directions, which are also randomised.

	if wall_detection == false and cadran_number != null:
		return (cadran_number * PI/2 + rng.randf_range(-PI/4,PI/4))
	else:
		var space_state = get_world_2d().direct_space_state
		var query
		var result
		var cadran_list = [0,1,2,3]
		for cad in banned_cadran:
			cadran_list.erase(cad)
		var angle_order_list = []
		if cadran_number != null:
			cadran_list.erase(cadran_number)
			cadran_list.shuffle()
			cadran_list.insert(0,cadran_number)
			cadran_number=null
		var tempo_angle
		for cad in cadran_list:
			tempo_angle = cad * PI/2 + rng.randf_range(-PI/4,PI/4)
			if wall_detection:
				query = PhysicsRayQueryParameters2D.create(global_position, global_position+Vector2(cos(tempo_angle)*wall_limit_range,sin(tempo_angle)*wall_limit_range))
				result = space_state.intersect_ray(query)
				if result == {} or not result["collider"] is TileMap:
					angle_order_list.append(tempo_angle)
				else:
					print("wall shit")
			else:
				angle_order_list.append(tempo_angle)
				
		if angle_order_list != []:
			return angle_order_list[0]
		else:
			return tempo_angle
"""
func start_moving(angle,movement_value,frame_data):
	moving = true
	movement_x = Regular_value.new("birbx",cos(angle)*movement_value,frame_data)
	movement_x.start()
	movement_y = Regular_value.new("birby",-sin(angle)*movement_value,frame_data)
	movement_y.start()

func not_on_floor_addon():
	pass

func convert_vector_to_cadran(vect:Vector2):
	match vect:
		Vector2(1,0):
			return 0
		Vector2(0,1):
			return 1
		Vector2(-1,0):
			return 2
		Vector2(0,-1):
			return 3

func calculate_movement_angle_by_target(target_position,movement_value,closing_in,wall_limit_range,wall_detection=true,banned_cadrans=[]):
	"""
	Returns the angle that will push the character the closest (closing_in is true) or the farthest (closing_in is false)
	For now wall detection is always on.
	For further details, check the documentation of func calculate_movement_angle from which it is a variant.
	"""
	var cadran_list = [0,1,2,3]
	for cadran in banned_cadrans:
		cadran_list.erase(cadran)
	var wall_cadrans_list = []
	var normal_cadrans_list = []
	var tempo_angle
	var tempo_position
	var space_state = get_world_2d().direct_space_state
	var query
	var result
	var ray
	var list
	for cad in cadran_list:
		tempo_angle = (cad * PI/2 + rng.randf_range(-PI/4,PI/4))
		tempo_position = Vector2(cos(tempo_angle)*movement_value,sin(tempo_angle)*movement_value)
		
		query = PhysicsRayQueryParameters2D.create(global_position, global_position+Vector2(cos(tempo_angle)*wall_limit_range,sin(tempo_angle)*wall_limit_range))
		result = space_state.intersect_ray(query)
		if result == {} or not result["collider"] is TileMap:
			ray = false
			list = normal_cadrans_list
		else:
			ray = true
			list = wall_cadrans_list
		var inserted = false
		var i = 0
		while not inserted and i<len(list)-1:
			i+=1
			if calculate_range(target_position,tempo_position) > calculate_range(target_position,list[i][1]):
				list.insert(i,[tempo_angle,tempo_position])
				inserted = true
		if not inserted:
			list.append([tempo_angle,tempo_position])
	normal_cadrans_list.append_array(wall_cadrans_list)
	return normal_cadrans_list[0]

func calculate_range(a:Vector2,b:Vector2):
	"""
	Returns the direct range between two points in 2dimensions
	"""
	return sqrt( (b.x-a.x)**2 + (a.y-b.y)**2 )
