extends Area2D
var gun_centre_ecart=Vector2(15,17)
var gun_scale=Vector2(0.8,0.8)
var collision
var user
var blasting = false
# Called when the node enters the scene tree for the first time.
func _ready():
	scale=gun_scale
	$blast.visible=false
	collision = $blastCollision
	collision.disabled = true
	#$blastArea/blastCollision.set_deferred("disabled",true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func rotate_gun(point):
	if not blasting:
		var angle=point.angle_to_point(get_global_mouse_position())
		position=gun_centre_ecart*Vector2(cos(angle),sin(angle))
		transform.x=Vector2(cos(angle),sin(angle))
		transform.y=Vector2(-sin(angle),cos(angle))
		scale=gun_scale

func blast():
	#$blastArea/blastCollision.set_deferred("disabled",false)
	blasting=true
	$blast.visible=true
	collision.disabled = false
	$blastTimer.start()

func _on_blast_timer_timeout():
	end_blast()

func end_blast():
	#$blastArea/blastCollision.set_deferred("disabled",true)
	$blast.visible=false
	collision.disabled = true
	blasting=false

func _on_body_entered(body):
	if raycast_to_target(body):
		if user == null:
			body.emit_signal("hit",self)
		else:
			body.emit_signal("hit",user)
			

func raycast_to_target(target):
	if target != null:
		var query = PhysicsRayQueryParameters2D.create(global_position, target.global_position)
		var result = get_world_2d().direct_space_state.intersect_ray(query)
		if result != {} and result["collider"] == target:
			return true
	return false
