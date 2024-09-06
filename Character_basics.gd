extends CharacterBody2D
class_name Character_basics
var root_node
var nodeCollision
var nodeSprite
var speed = 400
var gravity = 1633
var exp_gravity = 0
var screen_size
var tempoclamp
var spawn_point = Vector2(0,0)
signal hit(hitter)
signal death
var type = "ennemy"
var direction = 0
var character_class_instance
var shapeCollision
var shapeRotated = false
var hp = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)
	set_floor_constant_speed_enabled(true)
	set_floor_snap_length(10)
	set_floor_max_angle(0.9)
	screen_size=get_viewport_rect().size
	position = spawn_point
	hit.connect(_on_hit)
	death.connect(_on_death)
	adaptShape()
		

func adaptShape():
	if nodeCollision != null:
		if nodeCollision.shape is CapsuleShape2D:
			if shapeRotated:
				shapeCollision = Vector2(nodeCollision.shape.height,nodeCollision.shape.radius)
			else:
				shapeCollision = Vector2(nodeCollision.shape.radius,nodeCollision.shape.height)
		elif nodeCollision.shape is RectangleShape2D:
			if shapeRotated:
				shapeCollision = Vector2(nodeCollision.shape.size.y,nodeCollision.shape.size.x)
			else:
				shapeCollision = Vector2(nodeCollision.shape.size.x,nodeCollision.shape.size.y)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	tempoclamp=Vector2(clamp(position.x,0,screen_size.x),clamp(position.y,0,screen_size.y))
	if position.x != tempoclamp.x:
		position.x=tempoclamp.x
		tempoclamp_addon_x()
	if position.y != tempoclamp.y:
		if position.y > tempoclamp.y:
			position = spawn_point
		else:
			position.y = tempoclamp.y
		tempoclamp_addon_y()
	
	process_addon(_delta)
	
	if is_on_floor():
		on_floor_addon()
	else:
		not_on_floor_addon()
		
	move_and_slide()
	velocity = Vector2(0,0)
	if hp <= 0:
		emit_signal("death")

func tempoclamp_addon_x():
	pass
func tempoclamp_addon_y():
	pass
func _on_hit(_hitter=null,_type="basic"):
	hp-=1

func _on_death():
	queue_free()

func process_addon(delta):
	exp_gravity += gravity*delta
	velocity.y = exp_gravity
	#apply_terrain_effects()

func on_floor_addon():
	exp_gravity = 0

func not_on_floor_addon():
	velocity.y = exp_gravity

func into_sign(f1:float):
	f1 = int(f1)
	if f1<0:
		return -1
	elif f1>0:
		return 1
	else:
		return 0
		
func has_same_sign(f1:float,f2:float):
	return f1<0 and f2<0 or f1>0 and f2>0

func swap():
	direction *= -1
	nodeSprite.scale.x *= -1
	nodeCollision.scale.x *= -1

func wall_detection(bodyPosition,bodyShape,body):
	if null in [bodyPosition,bodyShape,body]:
		assert(false,"Null start value")
	for i in body.get_slide_collision_count():
		if body.get_slide_collision(i).get_collider() is TileMap:
			var posi = body.get_slide_collision(i).get_position()
			if not has_same_sign(bodyPosition.x - posi.x,direction) :
				if posi.y - bodyPosition.y <= float(bodyShape.y)/2:
					return true

func no_ground_detection(bodyPosition,bodyShape):
	var posi = Vector2(bodyPosition.x,bodyPosition.y) 
	var ground_posi = Vector2(posi.x,posi.y + float(bodyShape.y)/2)
	posi = Vector2(ground_posi.x+ (float(bodyShape.x)/2 * direction),ground_posi.y)
	posi = root_node.get_tile_position(posi)
	ground_posi = root_node.get_tile_position(ground_posi)
	posi.y += 1
	ground_posi.y += 1
	var tile = root_node.get_tile_from_tile_position(posi)
	var ground_tile = root_node.get_tile_from_tile_position(ground_posi)
	if ground_tile != null and tile == null:
		return true
	else:
		return false


func detect_terrain_effect(body):
	
	for i in body.get_slide_collision_count():
		if body.get_slide_collision(i).get_collider() is TileMap:
			var posi = body.get_slide_collision(i).get_position()
			posi -= body.get_slide_collision(i).get_normal() * 8
			posi = root_node.get_tile_position(posi)
			var tile = root_node.get_tile_from_tile_position(posi)
			if tile != null:
				if tile.get_custom_data("dangerous"):
					dangerous_terrain_behavior(body)

func dangerous_terrain_behavior(_body):
	pass
	
