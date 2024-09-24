extends Control

var root_node
var level1 = preload("res://level1.tscn").instantiate()
var level2 = preload("res://level2.tscn").instantiate()
var level4 = preload("res://level4.tscn").instantiate()
var levelAmaury1 = preload("res://levelAmaury1.tscn").instantiate()
var levelAmaury2 = preload("res://levelAmaury2.tscn").instantiate()
var levelAmaury3 = preload("res://levelAmaury3.tscn").instantiate()
var levelRamachnid = preload("res://levelRamachnid.tscn").instantiate()
var tutorial = preload("res://tutorial.tscn").instantiate()
var credits = preload("res://credits.tscn").instantiate()
var congrats = preload("res://congrats.tscn").instantiate()
var levelEasy = preload("res://levelEasy2.tscn").instantiate()
var level_list= [level1,level2,level4,levelAmaury1,levelAmaury2,levelAmaury3]
var level_to_button_dict
# Called when the node enters the scene trepasse for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)
	
func _process(_delta):
	if Input.is_action_just_pressed("return_menu"):
		root_node.quit_game()
	if checkGameWon():
		showCongrats()

func _on_level_2_pressed():
	root_node.load_level_scene(level1)
	root_node.remove_child(self)

func _on_level_1_pressed():
	root_node.load_level_scene(levelEasy)
	root_node.remove_child(self)


func _on_level_3_pressed():
	root_node.load_level_scene(levelAmaury3)
	root_node.remove_child(self)



func _on_level_4_pressed():
	root_node.load_level_scene(level4)
	root_node.remove_child(self)

func _on_level_5_pressed():
	root_node.load_level_scene(level2)
	root_node.remove_child(self)

func _on_level_6_pressed():
	root_node.load_level_scene(levelAmaury2)
	root_node.remove_child(self)

func _on_level_7_pressed():
	root_node.load_level_scene(levelRamachnid)
	root_node.remove_child(self)

func _on_level_8_pressed():
	root_node.load_level_scene(congrats)
	root_node.remove_child(self)

func _on_amaury_level_og_pressed():
	root_node.load_level_scene(levelAmaury1)
	root_node.remove_child(self)

func _on_button_pressed():
	root_node.quit_game()

func get_checkmark(level):
	var levelCheckmark
	match level:
		levelEasy:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer2/level1/TextureRect
		level1:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer3/level2/TextureRect
		levelAmaury3:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer/level3/TextureRect
		level4:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer4/level4/TextureRect
		level2:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer5/level5/TextureRect
		levelAmaury2:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/MarginContainer6/level6/TextureRect
		levelRamachnid:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/level7/level7/TextureRect
		congrats:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/level8/level8/TextureRect
		levelAmaury1:
			levelCheckmark = $MarginContainer/VBoxContainer/MarginContainer/GridContainer/Amaury/amauryLevelOg/TextureRect
	return levelCheckmark

func show_checkmark(level):
	get_checkmark(level).visible = true

func _on_tutorial_pressed():
	root_node.add_page(tutorial)
	root_node.remove_child(self)

func _on_credits_pressed():
	root_node.add_page(credits)
	root_node.remove_child(self)

func checkGameWon():
	for lev in [levelEasy,level1,levelAmaury3,level4,level2,levelAmaury2,levelRamachnid]:
		if not get_checkmark(lev).visible:
			return false
	return true

func showCongrats():
	$MarginContainer/VBoxContainer/MarginContainer/GridContainer/level8/level8.visible = true
	$MarginContainer/VBoxContainer/MarginContainer/GridContainer/level8/level8.disabled = false
