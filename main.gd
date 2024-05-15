extends Node2D

var _instance=self

var actual_level 
var actual_map 
var level2 = preload("res://level2.tscn").instantiate()
var level3 = preload("res://level3.tscn").instantiate()
var level4 = preload("res://level4.tscn").instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	actual_level = $Level
	actual_map = $Level


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if actual_level != $Level:
		apply_dangerous_ground_effect($player)
	if Input.is_action_just_pressed("down"):
		pass
		#switch_level(level4)
	if Input.is_action_just_pressed("action2"):
		print(get_tile($ennemy,detect_tile_position($ennemy)))

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
		actual_level.free()
		get_tree().root.add_child(level)
		actual_level=level
		actual_map = actual_level.get_node("TileMap")
		$player.position = actual_level.get_node("player_spawn").position
		$dummy.position = actual_level.get_node("dummy_spawn").position


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
