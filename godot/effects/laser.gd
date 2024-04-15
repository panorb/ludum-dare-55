extends Node3D


# externally initialized variable which should be on the level scene
# the laser will track this target
@onready var laser_target: Node2D
@onready var environment_viewport: SubViewport

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func project_screen_to_world(screen_pos: Vector2) -> Vector3:
	var camera = environment_viewport.get_camera_3d()
	var viewport_size = camera.get_viewport().get_visible_rect().size
	var nx = (screen_pos.x / viewport_size.x) * 2.0 - 1.0
	var ny = (1.0 - screen_pos.y / viewport_size.y) * 2.0 - 1.0  # Invert Y

	# NDC to 3D point in camera space
	# var near_plane_z = -camera.near  # Use negative near plane distance
	var p_ndc = Vector4(nx, ny, -1, 1.0)

	# Get the projection matrix and its inverse
	var projection = camera.get_camera_projection()
	var inv_projection = projection.inverse()

	# Transform the NDC point by the inverse projection matrix
	var p_camera = inv_projection * p_ndc

	# Divide by w to get correct coordinates (perspective divide)
	p_camera /= p_camera.w

	# Transform the camera space point to world space
	var world_point = camera.global_transform * Vector3(p_camera.x, p_camera.y, p_camera.z)

	return world_point

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if laser_target == null || environment_viewport == null:
		return

	var level_coords = project_screen_to_world(laser_target.global_position)

	look_at(level_coords)
