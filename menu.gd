extends Control

var root_node
var level1 = preload("res://level1.tscn").instantiate()
var level2 = preload("res://level2.tscn").instantiate()
var levelAmaury1 = preload("res://levelAmaury1.tscn").instantiate()
var levelAmaury2 = preload("res://levelAmaury2.tscn").instantiate()
var levelAmaury3 = preload("res://levelAmaury3.tscn").instantiate()
# Called when the node enters the scene trepasse for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_level_2_pressed():
	root_node.load_level_scene(level2)
	root_node.remove_child(self)

func _on_level_1_pressed():
	root_node.load_level_scene(level1)
	root_node.remove_child(self)
