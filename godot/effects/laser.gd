extends Node3D

@onready var target = null;
@onready var calculate_lookat = null;

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if calculate_lookat != null && target != null:
		var target_to_look_at = calculate_lookat.call(target.position)
		print(target_to_look_at)
		look_at(target_to_look_at)
