extends Ennemy_basics

var limit_distance = 1000

func _ready():
	super()
	nodeCollision = $CollisionShape2D
	nodeSprite = $Sprite2D
	speed = 100
	shapeRotated = true
	adaptShape()

func analyse_and_switch():
	pass

func idle_behavior():
	pass

func attack_behavior():
	var distance = sqrt((target_body.position.x**2)+(target_body.position.y**2))
	if  distance < limit_distance:
		#switch_to_flee()
		pass
	else:
		shoot(target_body)

func find_behavior():
	pass

func flee_behavior():
	pass

func _on_vision_body_entered(body):
	switch_to_attack()
	target_body = body

func shoot(target):
	pass
