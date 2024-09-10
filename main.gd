extends Node2D

var root_node 


var main_menu = preload("res://menu.tscn").instantiate()
var character_list=[] 
var actual_scene 
var actual_tilemap
var effects_list = ["dangerous"]

func _ready():
	root_node = get_tree().root.get_child(0)
	add_child(main_menu)

func _process(_delta):
	if Input.is_action_just_pressed("return_menu"):
		return_to_menu()
		#reset_level()

func return_to_menu():
	print_tree_pretty()
	add_child(main_menu)
	delete_level_scene(actual_scene)
	print_tree_pretty()

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
	#level_scene.add_child($bulletSlots)
	actual_scene=level_scene
	actual_tilemap = find_tilemap(actual_scene)
	spawn_to_position_markers(actual_scene)

func delete_level_scene(level_scene):
	remove_child(level_scene)
	var character_list_2 = character_list.duplicate()
	print("deleting all ",len(character_list))
	for character in character_list_2:
		character.remove_character()

func get_tile_position(other_position):
	if actual_scene != null:
		return actual_tilemap.local_to_map(other_position)


func get_tile_from_tile_position(tile_position):
	if actual_scene != null:
		return actual_tilemap.get_cell_tile_data(0, tile_position)

func reset_level():
	delete_level_scene(actual_scene)
	load_level_scene(actual_scene)

func get_actual_level():
	return actual_scene

func search_and_delete_character(target_charac_scene):
	for character in character_list:
		if character.scene == target_charac_scene:
			character.remove_character()
			
func quit_game():
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
