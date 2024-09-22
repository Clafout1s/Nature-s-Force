extends StaticBody2D

var direction_angle = 0
var total_speed = 0
var frame_speed = 0
var duration_frames = 1
var moving_frames = 0
signal hit
signal endBullet
var in_action = false
# Called when the node enters the scene tree for the first time.
func _ready():
	rotate(direction_angle)
	top_level = true
	$Area2D.hit.connect(_on_hit)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if in_action:
		moving_frames+=1
		position.x += cos(direction_angle)*frame_speed
		position.y += sin(direction_angle)*frame_speed
		if moving_frames >= duration_frames:
			end()

func launch(new_angle=0,new_speed=0,new_frames=1,new_scale=1):
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

func _on_area_2d_body_entered(body):
	end()

func _on_hit(_body = null,type="basic"):
	if type == "blade":
		end()
