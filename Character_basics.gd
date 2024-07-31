extends CharacterBody2D
class_name Character_basics
var root_node
var speed = 400
var gravity = 1633
var exp_gravity = 0
var screen_size
var tempoclamp
var spawn_point = Vector2(0,0)
signal hit(hitter)
var type = "ennemy"
var direction = 0
var character_class_instance
# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)
	set_floor_constant_speed_enabled(true)
	set_floor_snap_length(10)
	set_floor_max_angle(0.9)
	screen_size=get_viewport_rect().size
	position = spawn_point
	hit.connect(_on_hit)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
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
	
	process_addon(delta)
	
	if is_on_floor():
		on_floor_addon()
	else:
		not_on_floor_addon()
		
	move_and_slide()
	velocity = Vector2(0,0)

func tempoclamp_addon_x():
	pass
func tempoclamp_addon_y():
	pass
func _on_hit(hitter=null):
	pass

func process_addon(delta):
	exp_gravity += gravity*delta
	velocity.y = exp_gravity
	apply_terrain_effects()

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


func apply_terrain_effects():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var map = collision.get_collider()
		if map is TileMap:
			var collipos = collision.get_position()
			collipos -= collision.get_normal() * 8
			var tile_position = map.local_to_map(collipos)
			var tile = map.get_cell_tile_data(0, tile_position)
			if tile != null:
				if tile.get_custom_data("dangerous"):
					emit_signal("hit")

