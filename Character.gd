extends Node
class_name Character

var id

var type
var scene
var root
var placed = false
var node
var stock_list

func _init(nid,ntype,nroot):
	id = nid
	type = ntype
	root = nroot
	stock_list = root.character_list
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
		_:
			assert(false, "wrong type of character")
func add_character():
	root.add_child(scene)
	stock_list.append(self)
	placed = true
	if type == "boar":
		root.need_floor_detection_list.append([self,"boar_floor"])
		root.need_wall_detection_list.append([self,"boar_wall"])
	
func remove_character():
	root.remove_child(scene)
	placed = false
	remove_from_list(stock_list)
	if type == "boar":
		remove_from_list(root.need_floor_detection_list)
		remove_from_list(root.need_wall_detection_list)

func remove_from_list(list):
	for i in range(len(list)):
		if type_string(typeof(list[0])) == "Array":
			if self in list[0]:
				list.remove_at(i)
		elif self == list[0]:
			list.remove_at(i)
		

