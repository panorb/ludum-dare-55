extends Control

@onready var level_viewport := %LevelViewport
@onready var environment_viewport := %EnvironmentViewport
@onready var environment_texture: TextureRect = $EnvironmentTexture
@onready var level_texture: TextureRect = $LevelTexture
@onready var level_subviewport: SubViewport = %LevelViewport
@onready var environment := %Environment
@onready var level := %Level
@onready var main_theme_sound = %MainThemeSound

@onready var health_bar_p1 = $UIOverlay/Grid/Player1/HealthBar
@onready var health_bar_p2 = $UIOverlay/Grid/Player2/HealthBar

const LEVEL_VIEW_MOVEMENT_SCALE = 1.45
const ENVIRONMENT_CAMERA_MOVEMENT_SCALE = 0.0005
const BOOK = preload("res://game/entities/book.tscn")

var delay = 0.0

func window_to_game_coords(window_pos:Vector2)->Vector2:
	var scaled_mouse_pos = window_pos / get_viewport_rect().size
	
	var mouse_x = -level.get_level_view_x() + (scaled_mouse_pos.x * level_viewport.size.x)
	var mouse_y = scaled_mouse_pos.y * level_viewport.size.y

	var res = Vector2(mouse_x, mouse_y)
	print(res)

	return res


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var mouse = window_to_game_coords(event.position)
			var indicator = level.create_indicator(mouse)
			aim_laser(event.position, indicator)

			print(screen_to_game_coords(event.position))
			

func _process(delta):
	var x_offset = level.get_player_offset()

	environment.move_view(x_offset * delta * ENVIRONMENT_CAMERA_MOVEMENT_SCALE)
	level.move_view(x_offset * -delta * LEVEL_VIEW_MOVEMENT_SCALE)
	
	%CameraPosLabel.text = "Camera: " + str(environment.get_camera_position())
	%CalculatedCameraLabel.text = "Calc. Camera: " + str(get_environment_camera_pos_from_level_x(level.get_level_view_x()))
	%LevelViewLabel.text = "Level: " + str(level.get_level_view_x())
	%CalculatedLevelViewLabel.text = "Calc. Level: " + str(get_level_x_from_environment_camera_pos(environment.get_camera_position()))

func get_level_x_from_environment_camera_pos(camera_pos: float):
	return -(camera_pos / ENVIRONMENT_CAMERA_MOVEMENT_SCALE) * LEVEL_VIEW_MOVEMENT_SCALE

func get_environment_camera_pos_from_level_x(level_x: float):
	return -(level_x / LEVEL_VIEW_MOVEMENT_SCALE) * ENVIRONMENT_CAMERA_MOVEMENT_SCALE

func _ready():
	#_on_window_size_changed()
	#get_tree().get_root().size_changed.connect(_on_window_size_changed)
	level.viewport_size = level_viewport.size
	level.total_level_width = abs(get_level_x_from_environment_camera_pos(1.0))
	%TotalLevelWidthLabel.text = "Total level width: " + str(get_level_x_from_environment_camera_pos(1.0))
	
	var players = get_tree().get_nodes_in_group("player")
	var health_bars = [health_bar_p1, health_bar_p2]
	var player_count = 1
	for i in range(player_count):
		print("Activating player "+str(i+1))
		players[i].set_active(true)
		health_bars[i].set_player(players[i])
	for i in range(player_count, len(health_bars)):
		print("Deactivating player "+str(i+1))
		players[i].set_active(false)
		health_bars[i].set_player(null)

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

func screen_to_game_coords(screen_pos: Vector2) -> Vector2:
	var game_size = Vector2(level_viewport.size)
	var screen_size = get_viewport_rect().size
	return game_size * (screen_pos / screen_size)

func aim_laser(screen_space: Vector2, indicator: Node2D):

	# rotate the laser to point at the click
	environment.laser.target = indicator
	environment.laser.calculate_lookat = project_screen_to_world




func _on_window_size_changed():
	environment_viewport.size = get_tree().get_root().size
