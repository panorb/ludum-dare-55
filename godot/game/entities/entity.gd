class_name Entity
extends Area2D

signal collision(obstacle)

var damage = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_body_entered)

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

func on_body_entered(body):
	body.take_damage(damage)
	body.inertia += (body.position-position).normalized()*700

func connect_signals(level):
	pass
