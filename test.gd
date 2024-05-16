extends Node2D

var level1 = preload("res://level1.tscn").instantiate()
var level2 = preload("res://level4.tscn").instantiate()
var actual_scene 
var actual_tilemap
# Called when the node enters the scene tree for the first time.
func _ready():
	load_level_scene(level1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed('action2'):
		pass
	detect_dangerous_ground_effect($player,$player.position)
		
func switch(level_scene):
	delete_level_scene(actual_scene)
	load_level_scene(level_scene)

func find_tilemap(level_scene):
	return level_scene.get_node("TileMap")

func find_position_markers(level_scene,people_list):
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
	find_position_markers(level_scene,["player"])

func delete_level_scene(level_scene):
	remove_child(level_scene)
	#level_scene.set_deferred("free",true)

func get_tile(tile_position):
	tile_position = actual_tilemap.local_to_map(tile_position)
	print(tile_position)
	tile_position.y += 2
	return actual_tilemap.get_cell_tile_data(0, tile_position)

func detect_dangerous_ground_effect(character,tile_position):
	var tile = get_tile(tile_position)
	if tile != null:
		var tile_effect = tile.get_custom_data("dangerous")
		if "hitable" in character and tile_effect:
			print("in")
			character.emit_signal("hit")
			find_position_markers(actual_scene,["player"])

func detect_tile_position_from_character(character):
	var tile_position = actual_tilemap.local_to_map(character.position)
	return tile_position
	
