extends Node2D

var root_node 

var level1 = preload("res://level1.tscn").instantiate()
var level3 = preload("res://level3.tscn").instantiate()
var level4 = preload("res://level4.tscn").instantiate()

var character_list=[] 
var need_wall_detection_list = []
var need_floor_detection_list = []
var actual_scene 
var actual_tilemap
var effects_list = ["dangerous"]

# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)
	load_level_scene(level1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	apply_all_terrain_effects()
	check_floor()
	check_wall()

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
	actual_scene=level_scene
	actual_tilemap = find_tilemap(actual_scene)
	spawn_to_position_markers(actual_scene)

func delete_level_scene(level_scene):
	remove_child(level_scene)
	level_scene.free()
	var character_list_2 = character_list.duplicate()
	for character in character_list_2:
		character.remove_character()

func get_tile_position(other_position):
	if actual_scene != null:
		return actual_tilemap.local_to_map(other_position)

func adapt_position(character,tile_position,adapt_name):
	if actual_scene != null:
		if adapt_name in character.adapted_positions_list :
			match adapt_name:
				'player_floor':
					tile_position.y += 2
				"ennemy_floor":
					tile_position += Vector2i(character.scene.direction,3)
				"ennemy_wall":
					tile_position += Vector2i(character.scene.direction*2,0)
		return tile_position

func get_tile_from_tile_position(tile_position):
	if actual_scene != null:
		return actual_tilemap.get_cell_tile_data(0, tile_position)

func apply_all_terrain_effects():
	if actual_scene != null:
		for character in character_list:
			if character.type in ("player") and character.placed:
				for effect in effects_list:
					apply_terrain_effect(character,effect)

func apply_terrain_effect(character,effect):
	if actual_scene != null:
		var character_node = character.scene
		var tile_position = adapt_position(character,get_tile_position(character_node.position),str(character.type)+"_floor")
		var tile = get_tile_from_tile_position(tile_position)
		if tile != null:
				if tile.get_custom_data(effect):
					if effect == "dangerous":
						dangerous_effect(character)
			
func dangerous_effect(character):
	var character_node = character.scene
	character_node.emit_signal("hit")

func check_wall():
	for i in range(len(need_wall_detection_list)):
		var character_found = need_wall_detection_list[i]
		var wall_position = adapt_position(character_found[0],get_tile_position(character_found[0].scene.position),character_found[1]) 
		if get_tile_from_tile_position(wall_position) != null:
			need_wall_detection_list[i][0].scene.emit_signal("wall_detected")

func check_floor():
	for i in range(len(need_floor_detection_list)):
		var character_found = need_floor_detection_list[i]
		var floor_position = adapt_position(character_found[0],get_tile_position(character_found[0].scene.position),character_found[1]) 
		if get_tile_from_tile_position(floor_position) == null:
			need_floor_detection_list[i][0].scene.emit_signal("no_floor_detected")
