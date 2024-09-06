extends StaticBody2D
var root_node

# Called when the node enters the scene tree for the first time.
func _ready():
	root_node = get_tree().root.get_child(0)


func _on_area_2d_body_entered(_body):
	root_node.return_to_menu()
