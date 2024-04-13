extends Control

@onready var environment_viewport := %EnvironmentViewport
@onready var level_texture: TextureRect = $LevelTexture
@onready var level_subviewport: SubViewport = %LevelViewport


func _ready():
	_on_window_size_changed()
	get_tree().get_root().size_changed.connect(_on_window_size_changed)


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