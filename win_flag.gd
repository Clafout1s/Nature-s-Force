extends StaticBody2D
var character_name = "win flag"
var root_node
var character_class_instance
var needs_unlocking = false
# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)
	if needs_unlocking:
		lock()

func _process(_delta):
	if needs_unlocking:
		if are_all_ennemies_dead():
			unlock()

func _on_area_2d_body_entered(_body):
	root_node.win_level_and_return_menu()

func lock():
	$Sprite2D.visible = false
	$Area2D/CollisionShape2D.disabled = true
	needs_unlocking = true

func unlock():
	$Sprite2D.visible = true
	$Area2D/CollisionShape2D.disabled = false
	needs_unlocking = false

func are_all_ennemies_dead():
	for character in root_node.character_list:
		if character.scene.character_name in ["bird","boar","Ramachnid"]:
			return false
	return true
