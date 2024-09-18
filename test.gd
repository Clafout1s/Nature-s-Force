extends Node2D

var second = preload("res://test_secondaire.tscn").instantiate()
# Called when the node enters the scene tree for the first time.
func _ready():
	print_tree_pretty()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("action1"):
		add_child(second)
		print_tree_pretty()
	if Input.is_action_just_pressed("action2"):
		second.queue_free()
		remove_child(second)
		print_tree_pretty()
