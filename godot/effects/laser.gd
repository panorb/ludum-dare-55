extends Node3D


# externally initialized variable which should be on the level scene
# the laser will track this target
@onready var laser_target: Node2D
@onready var environment_viewport: SubViewport
@onready var level_viewport: SubViewport
@onready var laser_mesh:MeshInstance3D = %MeshInstance3D

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
	if not is_instance_valid(laser_target) or \
		not is_instance_valid(environment_viewport) or \
		not is_instance_valid(level_viewport):
		queue_free()
		return

	# get the position of this laser_target.global_position
	# with regards to the level_viewport

	var level_coords = laser_target.global_position
	var environment_screenspace_coords = level_to_environment_coords(level_coords)

	var target_coords = project_screen_to_world(environment_screenspace_coords)

	resize_laser()

	look_at(target_coords)

func level_to_environment_coords(level_coords: Vector2) -> Vector2:
	var level_vp_size = Vector2(level_viewport.get_size())
	var environment_vp_size = Vector2(environment_viewport.get_size())

	var environment_screenspace_coords = environment_vp_size * level_coords / level_vp_size

	return environment_screenspace_coords

func get_indicator_dimensions(node: Node2D)->Vector2:
	if not is_instance_valid(node) or (node as LaserIndicator) == null:
		return Vector2.ONE

	
	var laser_indicator = node as LaserIndicator

	var indicator_x = laser_indicator.laser_radius_indicator.global_position.x
	var laser_dimensions = (Vector2.ONE * indicator_x) - laser_indicator.global_position

	return laser_dimensions

func resize_laser():
	if not is_instance_valid(laser_target) or \
		not is_instance_valid(environment_viewport) or \
		not is_instance_valid(level_viewport):
		return
	
	var original_size = laser_mesh.get_aabb().size
	var indicator_size = get_indicator_dimensions(laser_target)

	var rightmost_position_gamespace = Vector2(indicator_size.x /2, 0) + laser_target.global_position

	var rightmost_pos_global = project_screen_to_world(rightmost_position_gamespace)

	var laser_center_global = project_screen_to_world(laser_target.global_position)

	print("Scale: ", scale)
	print("Indicator Size: ", indicator_size)

	var new_scale = rightmost_pos_global.distance_to(laser_center_global) / original_size.x

	var some_random_value_that_makes_it_fit = 2.6
	scale.x = new_scale * some_random_value_that_makes_it_fit
	scale.y = new_scale * some_random_value_that_makes_it_fit
