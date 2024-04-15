@tool
extends Sprite3D

# Rotation in radians
@export_range(-180.0, 180.0) var sprite_rotation : float = 0.0
# Upright position (still rotateable)
@export var y_billboard = false

func _process(_delta: float) -> void:
	# Get camera coordinates
	var cam : Camera3D = %Camera3D
	var look_pos : Vector3 = cam.global_position
	
	# If billboard should be upright, look at camera, but at the height of the object itself
	if y_billboard:
		look_pos.y = global_position.y
	
	# First look directly at the camera, then rotate around own axis
	# Note: as an up axis here is camera's up, but one might want to use Vector3.UP instead
	look_at(look_pos, cam.global_transform.basis.y)
	rotate_object_local(Vector3.FORWARD, deg_to_rad(sprite_rotation))
