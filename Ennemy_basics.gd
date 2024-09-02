extends Character_basics
class_name Ennemy_basics

var state = "idle"
var target_body
var space_state

func _ready():
	super()
	space_state= get_world_2d().direct_space_state
	
func process_addon(delta):
	exp_gravity += gravity*delta
	velocity.y = exp_gravity
	analyse_and_switch()
	chose_behavior()

func analyse_and_switch():
	pass

func chose_behavior():
	if state == "attack":
		attack_behavior()
	elif state == "idle":
		idle_behavior()
	elif state == "find":
		find_behavior()
	elif state == "flee":
		flee_behavior()

func attack_behavior():
	pass
func idle_behavior():
	pass
func find_behavior():
	pass
func flee_behavior():
	pass

func switch_to_idle():
	state = "idle"
func switch_to_attack():
	state = "attack"
func switch_to_find():
	state = "find"
func switch_to_flee():
	state = "flee"

func raycast_to_target(target = target_body):
	if target != null:
		var query = PhysicsRayQueryParameters2D.create(position, target.position)
		var result = space_state.intersect_ray(query)
		if result != {} and result["collider"] == target:
			return true
	return false
