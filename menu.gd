extends Control

var root_node
var level1 = preload("res://level1.tscn").instantiate()
var level2 = preload("res://level2.tscn").instantiate()
var level4 = preload("res://level4.tscn").instantiate()
var levelAmaury1 = preload("res://levelAmaury1.tscn").instantiate()
var levelAmaury2 = preload("res://levelAmaury2.tscn").instantiate()
var levelAmaury3 = preload("res://levelAmaury3.tscn").instantiate()
var level_list= [level1,level2,level4,levelAmaury1,levelAmaury2,levelAmaury3]
var level_to_button_dict
# Called when the node enters the scene trepasse for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)
	level_to_button_dict = {level1:$MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer2/level1,level2:$MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer3/level2,levelAmaury2:$MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer/level3,level4:$MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer4/level4}
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_level_2_pressed():
	root_node.load_level_scene(level2)
	root_node.remove_child(self)

func _on_level_1_pressed():
	root_node.load_level_scene(level1)
	root_node.remove_child(self)


func _on_level_3_pressed():
	root_node.load_level_scene(levelAmaury2)
	root_node.remove_child(self)



func _on_level_4_pressed():
	root_node.load_level_scene(level4)
	root_node.remove_child(self)


func _on_button_pressed():
	root_node.quit_game()

func show_checkmark(level):
	var level_button = level_to_button_dict[level]
	level_button.get_node("TextureRect").visible = true

