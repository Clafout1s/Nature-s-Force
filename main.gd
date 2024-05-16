extends Node2D

var level1 = preload("res://level1.tscn").instantiate()
var level4 = preload("res://level4.tscn").instantiate()
var actual_scene 
var actual_tilemap
var effects_list = ["dangerous"]
# Called when the node enters the scene tree for the first time.
func _ready():
	load_level_scene(level1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('action2'):
		switch(level4)
	apply_all_terrain_effects(["player"])
		
func switch(level_scene):
	delete_level_scene(actual_scene)
	load_level_scene(level_scene)

func find_tilemap(level_scene):
	return level_scene.get_node("TileMap")

func go_to_position_markers(level_scene,people_list):
	for character in people_list:
		if has_node(character):
			var node = get_node(character)
			if level_scene.has_node(character+"_spawn"):
				node.position = level_scene.get_node(character+"_spawn").position
			else:
				node.position = Vector2(0,0)
		else:
			assert(false, "wrong character name")

func load_level_scene(level_scene):
	add_child(level_scene)
	actual_scene=level_scene
	actual_tilemap = find_tilemap(level_scene)
	go_to_position_markers(level_scene,["player"])

func delete_level_scene(level_scene):
	remove_child(level_scene)
	level_scene.set_deferred("free",true)


func get_tile_position(other_position):
	return actual_tilemap.local_to_map(other_position)

func adapt_position(character,tile_position):
	if character == "player":
		tile_position.y += 2
	return tile_position

func get_tile_from_tile_position(tile_position):
	return actual_tilemap.get_cell_tile_data(0, tile_position)

func apply_all_terrain_effects(character_list):
	for character in character_list:
		for effect in effects_list:
			apply_terrain_effect(character,effect)

func apply_terrain_effect(character,effect):
	var character_node = get_node(character)
	var tile_position = adapt_position(character,get_tile_position(character_node.position))
	var tile = get_tile_from_tile_position(tile_position)
	if tile != null:
			if tile.get_custom_data(effect):
				if effect == "dangerous":
					dangerous_effect(character)
			
func dangerous_effect(character):
	var character_node = get_node(character)
	character_node.emit_signal("hit")
	go_to_position_markers(actual_scene,[character])
