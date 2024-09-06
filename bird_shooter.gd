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
var flee_start_range = 500

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
	if state != "flee" and target_body!= null and raycast_to_target() and calculate_range(global_position,target_body.global_position)<=flee_start_range:
		switch_to_flee()
	if state == "idle":
		if raycast_to_target():
			switch_to_attack()
		if moving == true and not movement_x.activated and not movement_y.activated:
			moving = false
	if state == "attack":
		if not raycast_to_target() and not target_in_sight:
			switch_to_idle()
	if state=="flee":
		if calculate_range(global_position,target_body.global_position) > flee_start_range:
			switch_to_idle()

func process_addon(_delta):
	velocity.x = movement_x.return_value()
	velocity.y = movement_y.return_value()
	analyse_and_switch()
	chose_behavior()

func idle_behavior():
	if not moving:
		start_moving(calculate_movement_angle_RANDOM(120),speed,movement_frames)

func attack_behavior():
	if not moving:
		start_moving(calculate_movement_angle_RANDOM(120),speed,movement_frames)
	
	if not has_same_sign(global_position.x  - target_body.global_position.x, direction):
		swap()
	if not bullet_instance.shooting and not reloading and not stunned and raycast_to_target():
		shoot(target_body)

func find_behavior():
	pass

func flee_behavior():
	if not moving:
		start_moving(calculate_movement_angle_BY_TARGET(target_body.position,false,120),speed,flee_frames)
	if not has_same_sign(global_position.x  - target_body.global_position.x, -direction):
		swap()
	if not bullet_instance.shooting and not reloading and not stunned and raycast_to_target():
		shoot(target_body)
		
func _on_vision_body_entered(body):
	target_body = body
	target_in_sight = true

func _on_vision_body_exited(_body):
	target_in_sight = false
	switch_to_idle()

func shoot(target):
	"Creates a bullet that goes to the target"
	if not bullet_instance.already_exists:
		root_node.add_child(bullet_instance)
		bullet_instance.hit_something.connect(_on_hit_something)
		bullet_instance.ending_bullet.connect(_on_bullet_end)
		bullet_instance.add_to_black_list(self)
	
	bullet_instance.global_position = global_position + Vector2(shapeCollision.x * direction,0)
	bullet_instance.angle = global_position.angle_to_point(target.global_position)
	bullet_instance.launch()
	

func _on_bullet_end():
	reloading = true
	$reloadTimer.start()
	
func _on_hit_something(body):
	if not body is TileMap:
		body.emit_signal("hit")

func _on_reload_timer_timeout():
	reloading = false

func _on_hit(_hitter = null,_damage_type="basic"):
	stunned = true
	queue_free()

func _on_damage_zone_body_entered(body):
	body.emit_signal("hit",self)

func calculate_movement_angle(wall_limit_range=0):
	"""
	Returns the angle for the bird to go. It uses a 4-sided cadran system, where priorities in directions are set in the favorite_directions
	global variable. The program first checks the favorite directions, then, if all are blocked by a wall, finds another direction to go.
	"""
	for i in favorite_directions:
		var test_angle = angle_by_cadran(i)
		if not is_wall_detected(test_angle,wall_limit_range):
			#if a more prefered cadran is not blocked by a wall anymore, it deletes the backup cadrans after it
			var index_i = favorite_directions.find(i)
			if index_i != len(favorite_directions)-1:
				favorite_directions = remove_from_list_to_index(favorite_directions,index_i)
			return test_angle
	var cadran_list = [0,1,2,3]
	var last_option = null # if all cadrns are blocked by walls, it will pick the best of them
	#handles the not favorite cadrans
	for i in favorite_directions:
		cadran_list.erase(i)
	cadran_list.shuffle()
	#tries to find cadrans close to the last prefered cadran and put it on top of the list
	if favorite_directions != []:
		last_option=favorite_directions[0]
		for i in cadran_list.duplicate():
			var ordered_cadran_dict = {0:[1,3],1:[0,2],2:[1,3],3:[2,0]}
			var number = favorite_directions.back()
			if i in ordered_cadran_dict[number]:
				cadran_list.insert(0,i)
	#checks for the last cadrans
	for i in cadran_list:
		if not is_wall_detected(i*PI/2,wall_limit_range):
			favorite_directions.append(i)
			return angle_by_cadran(i)
		if cadran_list.find(i)==0 and last_option == null:
			last_option = i
	#if all cadrans are blocked
	return angle_by_cadran(last_option)

func calculate_movement_angle_RANDOM(wall_limit_range=0):
	"""
	A wrapper to calculate_movement_angle that doesnt use favorite directions, and is therefore random.
	"""
	favorite_directions = []
	return calculate_movement_angle(wall_limit_range)

func calculate_movement_angle_BY_TARGET(target_position:Vector2,closing_in=true,wall_limit_range=0):
	"""
	A wrapper to calculate_movement_angle that directs itself by a targe. By defaults it tries to move towards the target, but if closing_in is false,
	it will try to go as far from the target as it can.
	"""
	var direction_cadran
	if not closing_in:
		#find the cadran that goes the furthest from target
		direction_cadran = Vector2(into_sign(global_position.x - target_position.x) , into_sign(global_position.y - target_position.y)) 
	else:
		#finds the cadran that goes the closest to the target
		direction_cadran = Vector2(into_sign(target_position.x - global_position.x) , into_sign(target_position.y - global_position.y))
	#simplifies the result to have only one direction (in x or in y, not both)
	if abs(global_position.x - target_body.position.x) > abs(global_position.y - target_body.position.y):
		direction_cadran.y = 0
	else:
		direction_cadran.x = 0
	var chosen_cadran = convert_vector_to_cadran(direction_cadran)
	if chosen_cadran not in favorite_directions:
		#replaces the general direction cadran by the new one without deleting the ones after it
		favorite_directions.pop_at(0)
		favorite_directions.insert(0,chosen_cadran)
	return calculate_movement_angle(wall_limit_range)

func remove_from_list_to_index(list,index):
	"""
	A worst slice because I couldn't read documentation correctly
	"""
	var final_list = []
	var i = 0
	while i <= index:
		final_list.append(list[i])
		i+=1
	return final_list

func angle_by_cadran(cadran_number):
	"""
	returns a random angle in the corresponding cadran. the angle is limited here, so diagonals are impossible
	"""
	return cadran_number * PI/2 + rng.randf_range(-PI/6,PI/6)

func is_wall_detected(chosen_angle,wall_limit_range):
	"""
	Returns true if a wall is detected in range (wall_limit_range)
	"""
	space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(global_position, global_position+Vector2(cos(chosen_angle)*wall_limit_range,-sin(chosen_angle)*wall_limit_range))
	var result = space_state.intersect_ray(query)
	return result != {} and result["collider"] is TileMap

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
		Vector2(0,-1):
			return 1
		Vector2(-1,0):
			return 2
		Vector2(0,1):
			return 3
	
func calculate_range(a:Vector2,b:Vector2):
	"""
	Returns the direct range between two points in 2dimensions
	"""
	return sqrt( (b.x-a.x)**2 + (a.y-b.y)**2 )


func _on_tree_exiting():
	if bullet_instance != null:
		bullet_instance.queue_free()
