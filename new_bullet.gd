extends StaticBody2D

var direction_angle = 0
var total_speed = 0
var frame_speed = 0
var duration_frames = 1
var moving_frames = 0
signal hit
signal endBullet
var in_action = false
var mortar_shot = false
var burst_x = 0
var burst_y = 0
var gravity = 0.4
var moving_gravity = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	rotate(direction_angle)
	top_level = true
	$Area2D.hit.connect(_on_hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if in_action:
		moving_frames+=1
		if not mortar_shot:
			position.x += cos(direction_angle)*frame_speed
			position.y += sin(direction_angle)*frame_speed
		else:
			moving_gravity+=gravity
			position.x += burst_x
			position.y += -burst_y + moving_gravity
			direction_angle = global_position.angle_to_point(Vector2(global_position.x+burst_x,global_position.y-burst_y+moving_gravity))
			rotation = direction_angle
		if moving_frames >= duration_frames:
				end()
			

func launch(new_angle=0,new_speed=0,new_frames=1):
	total_speed = new_speed
	direction_angle = new_angle
	duration_frames = new_frames
	moving_frames = 0
	frame_speed = total_speed / float(duration_frames)
	in_action = true
	rotation = new_angle

func end():
	in_action = false
	moving_frames = 0
	emit_signal("endBullet")

func hide_bullet():
	pass

func show_bullet():
	pass

func _on_area_2d_body_entered(_body):
	end()

func _on_hit(_body = null,type="basic"):
	if type == "blade":
		end()

func mortar_launch(new_burst_y,new_burst_x,new_frames):
	if mortar_shot:
		burst_y = new_burst_y
		burst_x = new_burst_x
		duration_frames = new_frames
		moving_frames = 0
		direction_angle = global_position.angle_to_point(Vector2(global_position.x+burst_x,global_position.y-burst_y))
		rotation = direction_angle
		in_action = true
