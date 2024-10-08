class_name Entity
extends Area2D

signal collision(obstacle)

var damage = 50
var entered_screen_once = false
var player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_body_entered)
	player = get_tree().get_first_node_in_group("player")

func _move(delta):
	pass

func _create_copies(level_width):
	if (has_node("Graphics")):
		var left_copy = get_node("Graphics").duplicate(DUPLICATE_USE_INSTANTIATION)
		left_copy.position.x = -level_width
		add_child(left_copy)
		
		var right_copy = get_node("Graphics").duplicate(DUPLICATE_USE_INSTANTIATION)
		right_copy.position.x = level_width
		add_child(right_copy)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_move(delta)

func on_player_collision(player):
	pass

func on_body_entered(body):
	on_player_collision(body)

func connect_signals(level):
	pass
