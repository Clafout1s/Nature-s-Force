extends StaticBody2D

var character_sword_gap = Vector2(30,30)
var sword_scale = Vector2(0.7,0.7)
var slash_frames = 15
var collision
var sprite
var slashing = false
var frame_count = slash_frames
var user
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
	area_or_body_entered(body)

func _on_damage_zone_area_entered(area):
	area_or_body_entered(area)
	
func area_or_body_entered(node):
	if user != null:
		if raycast_to_target(node):
			node.emit_signal("hit",user,"blade")
	else:
		node.emit_signal("hit",self,"blade")

func raycast_to_target(target):
	if target != null:
		var query = PhysicsRayQueryParameters2D.create(user.global_position, target.global_position)
		var result = get_world_2d().direct_space_state.intersect_ray(query)
		if result == {} or not result["collider"] is TileMap:
			return true
	return false


