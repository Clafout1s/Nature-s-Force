extends Node2D

var root_node 

var level1 = preload("res://level1.tscn").instantiate()
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
	var player1 = Character.new("player1","player",root_node)
	var ennemy1 = Character.new("ennemy1","ennemy",root_node)
	player1.add_character()
	ennemy1.add_character()
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

func go_to_position_markers(level_scene,people_list):
	for character in people_list:
		if character.placed and level_scene.has_node(str(character.type)+"_spawn"):
			character.scene.position = level_scene.get_node(str(character.type)+"_spawn").position
			if "spawn_point" in character.scene:
				character.scene.spawn_point = level_scene.get_node(str(character.type)+"_spawn").position
		else:
			character.scene.position = Vector2(0,0)
			if "spawn_point" in character.scene:
				character.scene.spawn_point = Vector2(0,0)

func load_level_scene(level_scene):
	add_child(level_scene)
	actual_scene=level_scene
	actual_tilemap = find_tilemap(level_scene)
	go_to_position_markers(level_scene,character_list)

func delete_level_scene(level_scene):
	remove_child(level_scene)
	level_scene.set_deferred("free",true)


func get_tile_position(other_position):
	return actual_tilemap.local_to_map(other_position)

func adapt_position(character,tile_position,adapt_name):
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
	return actual_tilemap.get_cell_tile_data(0, tile_position)

func apply_all_terrain_effects():
	for character in character_list:
		if character.type in ("player") and character.placed:
			for effect in effects_list:
				apply_terrain_effect(character,effect)

func apply_terrain_effect(character,effect):
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
	go_to_position_markers(actual_scene,[character])

func check_wall():
	for i in range(len(need_wall_detection_list)):
		var character_found = need_wall_detection_list[i]
		var wall_position = adapt_position(character_found[0],get_tile_position(character_found[0].scene.position),character_found[1]) 
		print(wall_position)
		if get_tile_from_tile_position(wall_position) != null:
			need_wall_detection_list[i][0].scene.emit_signal("wall_detected")

func check_floor():
	for i in range(len(need_floor_detection_list)):
		var character_found = need_floor_detection_list[i]
		var floor_position = adapt_position(character_found[0],get_tile_position(character_found[0].scene.position),character_found[1]) 
		if get_tile_from_tile_position(floor_position) == null:
			need_floor_detection_list[i][0].scene.emit_signal("no_floor_detected")
