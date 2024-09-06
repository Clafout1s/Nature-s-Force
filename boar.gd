extends Ennemy_basics


var target_in_vision
var last_target_position
var stunned = false
var stun_recoil 
var stun_attack_passed=false

func _ready():
	super()
	space_state= get_world_2d().direct_space_state
	nodeCollision = $CollisionShape2D
	nodeSprite = $Sprite2D
	direction = 1
	swap()
	speed = 200
	shapeRotated = true
	adaptShape()
	hp = 3
	
func process_addon(delta):
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
		if stunned:
			switch_to_idle()

func idle_behavior():
	if not stunned:
		if wall_detection(position,shapeCollision,self):
			swap()
		if no_ground_detection(position,shapeCollision):
			swap()
		velocity.x = speed * direction
	else:
		velocity.x = stun_recoil.return_value()

func attack_behavior():
	var tempo = target_body.global_position.x - global_position.x
	if abs(tempo) > 80:
		tempo = into_sign(tempo)
	else:
		tempo = direction
	if not has_same_sign(tempo,direction):
		swap()
	velocity.x = tempo * (speed * 200/float(100))
	if wall_detection(position,shapeCollision,self):
		switch_to_idle()

func find_behavior():
	var tempo = into_sign(last_target_position.x - global_position.x)
	if not has_same_sign(tempo,direction):
		swap()
	var movement = direction * move_toward(0,last_target_position.x,abs(speed))
	velocity.x = movement
	if abs(last_target_position.x - global_position.x) < float(shapeCollision.x)/2 or no_ground_detection(position,shapeCollision) or wall_detection(position,shapeCollision,self):
		switch_to_idle()

func switch_to_attack():
	if not stunned:
		super()

func switch_to_find():
	if not stunned:
		super()
		last_target_position = target_body.global_position

func _on_vision_body_entered(body):
	target_body = body
	target_in_vision = true

func _on_vision_body_exited(_body):
	target_in_vision = false
	

func _on_damage_zone_body_entered(body):
	body.emit_signal("hit")
	
func _on_hit(hitter=null,damage_type="basic"):
	print(hitter)
	if damage_type == "blade":
		hp-=1
		
		start_stun(hitter)
		stun_attack_passed=true
	else:
		start_stun(hitter)
	
func start_stun(hitter):
	if not stunned:
			
		stunned = true
		stun_attack_passed=false
		$stunTimer.start()
		$damage_zone/CollisionShape2D.set_deferred("disabled",true)
		switch_to_idle()
		if hitter == null:
			stun_recoil = Regular_value.new("boar recoil",-direction * 4000,5,true,10)
		else:
			var dir = into_sign(position.x - hitter.global_position.x)
			stun_recoil = Regular_value.new("boar recoil",dir * 4000,5,true,10)
		stun_recoil.start()

func _on_stun_timer_timeout():
	$damage_zone/CollisionShape2D.set_deferred("disabled",false)
	stunned = false

