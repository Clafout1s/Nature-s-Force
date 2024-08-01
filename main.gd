extends Node2D

var root_node 


var main_menu = preload("res://menu.tscn").instantiate()
var character_list=[] 
var need_wall_detection_list = []
var need_floor_detection_list = []
var actual_scene 
var actual_tilemap
var effects_list = ["dangerous"]

# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)
	add_child(main_menu)
	#load_level_scene(main_menu.levelAmaury3)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#check_floor()
	#check_wall()
	if Input.is_action_just_pressed("return_menu"):
		add_child(main_menu)
		delete_level_scene(actual_scene)
		if has_node("bulletSlotsUI"):
			remove_child($bulletSlotsUI)

func switch(level_scene):
	delete_level_scene(actual_scene)
	load_level_scene(level_scene)

func find_tilemap(level_scene):
	return level_scene.get_node("TileMap")

func spawn_to_position_markers(level_scene):
	if "spawn_point_list" in level_scene:
		var spawn_list = level_scene.spawn_point_list
		for i in range(len(spawn_list)):
			var new_charac = Character.new(str(spawn_list[i][0]),spawn_list[i][1],root_node)
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
	for character in character_list_2:
		character.remove_character()

func get_tile_position(other_position):
	if actual_scene != null:
		return actual_tilemap.local_to_map(other_position)


func get_tile_from_tile_position(tile_position):
	if actual_scene != null:
		return actual_tilemap.get_cell_tile_data(0, tile_position)


