extends Node
class_name Character

var id

var type
var scene
var root
var placed = false
var node
var stock_list

func _init(nid,ntype,nroot,special_rules=[]):
	id = nid
	type = ntype
	root = nroot
	stock_list = root.character_list
	if special_rules == null:
		special_rules = []
	match type:
		"player":
			scene = preload("res://player.tscn").instantiate() 
			#adapted_positions_list.append("player_floor")
			scene.character_class_instance = self
		"boar":
			scene = preload("res://boar.tscn").instantiate()
			#adapted_positions_list.append("boar_wall")
			#adapted_positions_list.append("boar_floor")
			scene.character_class_instance = self
			
		"dummy":
			scene = preload("res://dummy.tscn").instantiate()
			scene.character_class_instance = self
		"bird":
			scene = preload("res://bird_shooter.tscn").instantiate()
			scene.character_class_instance = self
		"flag":
			scene = preload("res://win_flag.tscn").instantiate()
			scene.character_class_instance = self
			if "need_unlock" in special_rules:
				scene.needs_unlocking = true
		_:
			assert(false, "wrong type of character")
func add_character():
	root.add_child(scene)
	stock_list.append(self)
	placed = true
	root.get_actual_level().character_list.append(scene)
	
func remove_character():
	if is_instance_valid(scene):
		scene.queue_free()
		root.remove_child.call_deferred(scene)
		remove_from_list(stock_list)
	placed = false
	

func remove_from_list(list):
	var num = len(list)
	var i = 0
	var finished = false
	while i < num and not finished:
		if self == list[i]:
			list.remove_at(i)
			finished = true
		i+=1
		

