extends Node2D

var _instance=self


var level1 = preload("res://level1.tscn").instantiate()
var level2 = preload("res://level2.tscn").instantiate()
var level3 = preload("res://level3.tscn").instantiate()
var level4 = preload("res://level4.tscn").instantiate()
var actual_level =level1
var actual_map  = level1.get_node("TileMap")

func _ready():
	load_level_scene(actual_level)


func _process(delta):
	#apply_dangerous_ground_effect($player)
	if Input.is_action_just_pressed("down"):
		switch(level4)

func apply_dangerous_ground_effect(character):
	var tile = get_tile(character,adapt_tile_position(character,detect_tile_position(character)))
	if tile != null:
		var tile_effect = tile.get_custom_data("dangerous")
		if "hitable" in character and tile_effect:
			character.emit_signal("hit")
			character.position = $spawnpoint.position

func detect_tile_position(character):
	var tile_position = actual_map.local_to_map(character.position)
	return tile_position

func adapt_tile_position(character,tile_position):
	if character == $player:
		tile_position.y+=2
	elif character ==  $ennemy:
		tile_position.y +=3
	return tile_position

func get_tile(character,tile_position):
	
	return actual_map.get_cell_tile_data(0, tile_position)

func switch_level(level):
	if actual_level != level:
		if actual_level != null:
			print("in")
			actual_level.queue_free()
		get_tree().root.add_child(level)
		actual_level=level
		actual_map = actual_level.get_node("TileMap")

		if actual_level.get_node_or_null("player_spawn") != null:
			$player.position = actual_level.get_node("player_spawn").position
		else:
			$player.position = Vector2(0,0)
		if actual_level.get_node_or_null("dummy_spawn") != null:
			$dummy.position = actual_level.get_node("dummy_spawn").position
		else:
			$dummy.position = Vector2(0,0)
		if actual_level.get_node_or_null("ennemy_spawn") != null:
			$ennemy.position = actual_level.get_node("ennemy_spawn").position
		else:
			$ennemy.position = Vector2(0,0)

func switch(level_scene):
	print("in")
	delete_level_scene(actual_level)
	load_level_scene(level_scene)

func load_level_scene(level_scene):
	add_child(level_scene)
		

func delete_level_scene(level_scene):
	remove_child(level_scene)
	level_scene.set_deferred("free",true)

func _on_ennemy_floor_detection_question(direction):
	var tile_position = adapt_tile_position($ennemy,detect_tile_position($ennemy))
	tile_position.x += direction
	if get_tile($ennemy,tile_position) == null:
		$ennemy.on_no_floor_detected()


func _on_ennemy_wall_detection_question(direction):
	var tile_position = detect_tile_position($ennemy)
	tile_position.x += direction*2
	if get_tile($ennemy,tile_position) != null:
		$ennemy.on_wall_detected()
