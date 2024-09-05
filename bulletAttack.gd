extends Area2D

signal hit
var distance_speed = 1500
var frame_speed = 400
var angle = 180
var bullet_scale = Vector2(0.5,0.5)
signal hit_something
signal ending_bullet
var bullet_movement_x
var bullet_movement_y
var root_node
var shooting = false
var body_black_list = []

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = Vector2( 1000,500)
	scale = bullet_scale
	global_rotation = angle
	root_node = get_tree().root.get_child(0)
	bullet_movement_x = Regular_value.new("bullet",distance_speed * float(cos(angle)),frame_speed)
	bullet_movement_y = Regular_value.new("bullet",distance_speed * float(sin(angle)),frame_speed)
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var movement_update = Vector2(bullet_movement_x.return_value(),bullet_movement_y.return_value())
	global_position += movement_update
	if shooting == true and Vector2(bullet_movement_x.return_value(), bullet_movement_y.return_value()) == Vector2(0,0):
		end_bullet()
	
func launch():
	end_bullet(true)
	$Sprite2D.visible = true
	$Sprite2D.global_rotation = angle + 3.14
	$CollisionShape2D.global_rotation = angle  + 1.7
	$CollisionShape2D.set_deferred("disabled",false)
	bullet_movement_x = Regular_value.new("bullet",distance_speed * float(cos(angle)),frame_speed)
	bullet_movement_y = Regular_value.new("bullet",distance_speed * float(sin(angle)),frame_speed)
	bullet_movement_x.start()
	bullet_movement_y.start()
	shooting = true

func end_bullet(when_reset = false):
	if not when_reset:
		emit_signal("ending_bullet")
	bullet_movement_x.global_end()
	bullet_movement_y.global_end()
	$Sprite2D.visible = false
	$CollisionShape2D.set_deferred("disabled",true)
	shooting = false

func _on_body_entered(body):
	if not body in body_black_list:
		emit_signal("hit_something",body)
		end_bullet()

func add_to_black_list(body):
	if body not in body_black_list:
		body_black_list.append(body)

func _on_hit_something(body):
	pass
	
func _on_hit(body = null,type="basic"):
	if type == "blade":
		end_bullet()

func _on_ending_bullet():
	pass # Replace with function body.
