extends StaticBody2D

var character_sword_gap = Vector2(10,10)
var sword_scale = Vector2(1,1)
var slash_frames = 15
var collision
var sprite
var slashing = false
var frame_count = slash_frames
# Called when the node enters the scene tree for the first time.
func _ready():
	scale = sword_scale
	collision = $damage_zone/damage_zone_hitbox
	sprite = $sprite
	disable_blade()
	rotate_sword(0)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if slashing:
		frame_count -= 1
		if frame_count <=0:
			frame_count = slash_frames
			end_slash()
			
func rotate_sword(angle):
	position=character_sword_gap*Vector2(cos(angle),sin(angle))
	transform.x=Vector2(cos(angle),sin(angle))
	transform.y=Vector2(-sin(angle),cos(angle))
	scale=sword_scale

func start_slash(point):
	var angle=point.angle_to_point(get_global_mouse_position())
	rotate_sword(angle)
	unable_blade()

func end_slash():
	disable_blade()

func disable_blade():
	sprite.visible = false
	collision.disabled = true
	slashing = false

func unable_blade():
	sprite.visible = true
	collision.disabled = false
	slashing = true


func _on_damage_zone_body_entered(body):
	body.emit_signal("hit")
