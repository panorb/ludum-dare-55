extends Control

@onready var level_viewport := %LevelViewport
@onready var environment_viewport := %EnvironmentViewport
@onready var level_texture: TextureRect = $LevelTexture
@onready var level_subviewport: SubViewport = %LevelViewport

const LEVEL_VIEW_MOVEMENT_SCALE = 1.45
const ENVIRONMENT_CAMERA_MOVEMENT_SCALE = 0.0005
const BOOK = preload("res://game/entities/book.tscn")

func _process(delta):
	var x_offset = level.get_player_offset(delta)
	if abs(x_offset) > 45.0:
		level.move_view(x_offset * -delta * LEVEL_VIEW_MOVEMENT_SCALE)
		environment.move_view(x_offset * delta * ENVIRONMENT_CAMERA_MOVEMENT_SCALE)
	%CameraPosLabel.text = "Camera: " + str(environment.get_camera_position())
	%CalculatedCameraLabel.text = "Calc. Camera: " + str(get_environment_camera_pos_from_level_x(level.get_level_view_x()))
	%LevelViewLabel.text = "Level: " + str(level.get_level_view_x())
	%CalculatedLevelViewLabel.text = "Calc. Level: " + str(get_level_x_from_environment_camera_pos(environment.get_camera_position()))
	# 

func get_level_x_from_environment_camera_pos(camera_pos: float):
	return -(camera_pos / ENVIRONMENT_CAMERA_MOVEMENT_SCALE) * LEVEL_VIEW_MOVEMENT_SCALE

func get_environment_camera_pos_from_level_x(level_x: float):
	return -(level_x / LEVEL_VIEW_MOVEMENT_SCALE) * ENVIRONMENT_CAMERA_MOVEMENT_SCALE

func _ready():
	_on_window_size_changed()
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	level.viewport_size = level_viewport.size
	


func convert_screen_space_to_playworld_space(screen_space_position: Vector2) -> Vector2:
	var a = (level_texture.size.x - level_texture.size.y / 180 * 320)/-2

	var x_factor = (level_subviewport.size.x + a) / level_texture.size.x
	var y_factor = level_subviewport.size.y / level_texture.size.y

	return (level_texture.get_global_transform().affine_inverse() * screen_space_position + Vector2(a, 0)) * 180 / level_texture.size.y

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			var mouse_pos = event.position
			print(convert_screen_space_to_playworld_space(mouse_pos))

func _on_window_size_changed():
	environment_viewport.size = get_tree().get_root().size


func _on_level_texture_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print(event.position)