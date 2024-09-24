extends Node2D

var root_node 


var main_menu = preload("res://menu.tscn").instantiate()
var character_list=[] 
var ui_list = []
var actual_scene 
var actual_tilemap
var effects_list = ["dangerous"]
var lifebar_scene = preload("res://playerLifeBar.tscn").instantiate()
var levelEasy2 = preload("res://levelEasy2.tscn").instantiate()
var levelAmaury3 = preload("res://levelAmaury3.tscn").instantiate()
var congrats = preload("res://congrats.tscn").instantiate()
var actual_page = null
func _ready():
	root_node = get_tree().root.get_child(0)
	add_child(main_menu)

func _process(_delta):
	if Input.is_action_just_pressed("return_menu"):
		return_to_menu()
	if Input.is_action_just_pressed("debug"):
		win_level_and_return_menu()

func return_to_menu():
	add_child(main_menu)
	if actual_scene != null:
		delete_level_scene(actual_scene)
	if actual_page != null:
		remove_page()

func switch(level_scene):
	delete_level_scene(actual_scene)
	load_level_scene(level_scene)

func find_tilemap(level_scene):
	return level_scene.get_node("TileMap")

func spawn_to_position_markers(level_scene):
	if "spawn_point_list" in level_scene:
		var spawn_list = level_scene.spawn_point_list
		for i in range(len(spawn_list)):
			var special_rules = []
			if len(spawn_list[i]) > 2:
				special_rules = spawn_list[i][2]
			var new_charac = Character.new(str(spawn_list[i][0]),spawn_list[i][1],root_node,special_rules)
			new_charac.add_character()
			new_charac.scene.position = spawn_list[i][0].position
			if "spawn_point" in new_charac.scene:
				new_charac.scene.spawn_point = spawn_list[i][0].position
	

func load_level_scene(level_scene):
	add_child(level_scene)
	actual_scene=level_scene
	actual_tilemap = find_tilemap(actual_scene)
	spawn_to_position_markers(actual_scene)

func delete_level_scene(level_scene):
	remove_child(level_scene)
	var character_list_2 = character_list.duplicate()
	for character in character_list_2:
		character.remove_character()
		
	var ui_list2 = ui_list.duplicate()
	for i in range(len(ui_list2)):
		var ui_ele = ui_list2[i]
		if is_instance_valid(ui_ele):
			#queue_free is a problem, remove_child is enough
			remove_child.call_deferred(ui_ele)
		ui_list.remove_at(0)
	actual_scene = null
	
func find_and_remove_ui(ui_target):
	var i = 0
	var finished = false
	while i<len(ui_list) and not finished:
		if ui_target == ui_list[i]:
			remove_child.call_deferred(ui_list[i])
			ui_list.remove_at(i)
			finished = true
		i+=1

func get_tile_position(other_position):
	if actual_scene != null:
		return actual_tilemap.local_to_map(other_position)


func get_tile_from_tile_position(tile_position):
	if actual_scene != null:
		return actual_tilemap.get_cell_tile_data(0, tile_position)

func reset_level():
	var scene_reseted = actual_scene
	delete_level_scene(scene_reseted)
	load_level_scene(scene_reseted)

func get_actual_level():
	return actual_scene

func search_and_delete_character(target_charac_scene):
	for character in character_list:
		if character.scene == target_charac_scene:
			character.remove_character()

func win_level_and_return_menu():
	var level = actual_scene
	return_to_menu()
	main_menu.show_checkmark(level)

func quit_game():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func add_ui(ui_name,ui_element,user):
	match ui_name:
		"lifebar":
			var scene = ui_element
			add_child(scene)
			ui_list.append(scene)
			user.lifebar = scene
			return scene
	
func add_page(page):
	assert(actual_page == null,"Page en trop !")
	actual_page = page
	add_child(actual_page)

func remove_page():
	remove_child(actual_page)
	actual_page = null
