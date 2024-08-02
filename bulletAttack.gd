extends Area2D

var distance_speed = 500
var frame_speed = 100
var angle = 0
var bullet_scale = Vector2(1,1)
signal hit_something
var bullet_movement_x
var bullet_movement_y

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = Vector2( 1000,500)
	scale = bullet_scale
	rotation = angle
	bullet_movement_x = Regular_value.new("bullet",distance_speed * float(cos(angle)),frame_speed)
	bullet_movement_y = Regular_value.new("bullet",distance_speed * float(sin(angle)),frame_speed)
	launch()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += Vector2(bullet_movement_x.return_value(),bullet_movement_y.return_value())

func launch():
	bullet_movement_x.start()
	bullet_movement_y.start()

func _on_body_entered(body):
	emit_signal("hit_something",body)

func _on_hit_something(body):
	print(body)
	bullet_movement_x.global_end()
	bullet_movement_y.global_end()
