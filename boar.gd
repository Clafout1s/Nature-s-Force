extends Ennemy_basics

signal no_floor_detected
signal wall_detected

var target_in_vision
var find_timer
var no_floor = false
var wall = false
var last_target_position
func _ready():
	super()
	space_state= get_world_2d().direct_space_state
	direction = 1
	speed = 200
	find_timer = $findTimer
	
func tempoclamp_addon_x():
	if state == "idle" :
		swap()

func process_addon(delta):
	velocity.x = 0
	super(delta)

func analyse_and_switch():
	if state == "idle":
		if target_in_vision and raycast_to_target():
			switch_to_attack()
	elif state == "attack":
		if not raycast_to_target():
			switch_to_find()
	elif state == "find":
		if raycast_to_target():
			switch_to_attack()
		elif find_timer.is_stopped():
			switch_to_idle()

func idle_behavior():
	check_terrain()
	velocity.x = speed * direction

func attack_behavior():
	var tempo = target_body.global_position.x - global_position.x 
	if abs(tempo) > 80:
		tempo = into_sign(tempo)
	else:
		tempo = direction

	if not has_same_sign(tempo,direction):
		swap()

	velocity.x = tempo * (speed * 200/float(100))

func find_behavior():
	check_terrain()
	var tempo = last_target_position.x - global_position.x
	if abs(tempo) > 80:
		tempo = into_sign(tempo)
	else:
		tempo = direction
	if not has_same_sign(tempo,direction):
		swap()
	velocity.x = tempo*speed
func switch_to_attack():
	super()
	find_timer.stop()

func switch_to_find():
	super()
	find_timer.start()
	last_target_position = target_body.global_position

func swap():
	direction *= -1
	$Sprite2D.scale.x *= -1

func _on_vision_body_entered(body):
	target_body = body
	target_in_vision = true

func _on_vision_body_exited(body):
	target_in_vision = false
	
func has_same_sign(f1:float,f2:float):
	return f1<0 and f2<0 or f1>0 and f2>0

func _on_damage_zone_body_entered(body):
	body.emit_signal("hit")

func _on_hit():
	position = spawn_point
	switch_to_idle()

func _on_no_floor_detected():
	no_floor = true

func _on_wall_detected():
	wall = true

func check_terrain():
	if no_floor or wall:
		swap()
		no_floor = false
		wall = false
