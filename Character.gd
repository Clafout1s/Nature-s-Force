extends Node
class_name Character

var id

var type
var scene
var root
var placed = false
var node
var stock_list
var adapted_positions_list = []

func _init(nid,ntype,nroot):
	id = nid
	type = ntype
	root = nroot
	stock_list = root.character_list
	match type:
		"player":
			scene = preload("res://player.tscn").instantiate() 
			adapted_positions_list.append("player_floor")
		"ennemy":
			scene = preload("res://ennemy.tscn").instantiate()
			adapted_positions_list.append("ennemy_wall")
			adapted_positions_list.append("ennemy_floor")
			
		"dummy":
			scene = preload("res://dummy.tscn").instantiate()
		_:
			assert(false, "wrong type of character")
func add_character():
	root.add_child(scene)
	stock_list.append(self)
	placed = true
	if type == "ennemy":
		root.need_floor_detection_list.append([self,"ennemy_floor"])
		root.need_wall_detection_list.append([self,"ennemy_wall"])
	
func remove_character():
	root.remove_child(scene)
	placed = false
	remove_from_list(stock_list)
	if type == "ennemy":
		remove_from_list(root.need_floor_detection_list)
		remove_from_list(root.need_wall_detection_list)

func remove_from_list(list):
	for i in range(len(list)):
		if self in list[0]:
			list.remove_at(i)

