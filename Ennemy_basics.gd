extends Character_basics
class_name Ennemy_basics

var state = "idle"
var target_body
var space_state

func _ready():
	super()
	space_state= get_world_2d().direct_space_state
	
func process_addon(delta):
	super(delta)
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

func attack_behavior():
	pass

func idle_behavior():
	pass

func find_behavior():
	pass

func switch_to_idle():
	state = "idle"

func switch_to_attack():
	state = "attack"

func switch_to_find():
	state = "find"

func raycast_to_target():
	if target_body != null:
		var query = PhysicsRayQueryParameters2D.create(position, target_body.position)
		var result = space_state.intersect_ray(query)
		if result != {} and result["collider"] == target_body:
			return true
	return false
