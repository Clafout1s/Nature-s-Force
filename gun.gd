extends StaticBody2D
var gun_centre_ecart=Vector2(10,15)
var gun_scale=Vector2(0.8,0.8)

# Called when the node enters the scene tree for the first time.
func _ready():
	scale=gun_scale
	$blast.visible=false
	$blastArea/blastCollision.set_deferred("disabled",true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func rotate_gun(point):
	var angle=point.angle_to_point(get_global_mouse_position())
	position=gun_centre_ecart*Vector2(cos(angle),sin(angle))
	transform.x=Vector2(cos(angle),sin(angle))
	transform.y=Vector2(-sin(angle),cos(angle))
	scale=gun_scale

func blast():
	$blastArea/blastCollision.set_deferred("disabled",false)
	$blast.visible=true
	$blastTimer.start()

func _on_blast_timer_timeout():
	end_blast()

func end_blast():
	$blastArea/blastCollision.set_deferred("disabled",true)
	$blast.visible=false



func _on_blast_area_body_entered(body):
	if "hitable" in body:
		body.emit_signal("hit")
