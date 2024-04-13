extends Control

@onready var environment_viewport := %EnvironmentViewport
@onready var level_viewport := %LevelViewport

func _ready():
	_on_window_size_changed()
	get_tree().get_root().size_changed.connect(_on_window_size_changed)

func _on_window_size_changed():
	environment_viewport.size = get_tree().get_root().size
	
	print(get_tree().get_root().size)
	level_viewport.size.x = (320.0 / 1280.0) * get_tree().get_root().size.x
	level_viewport.size.y =  (180.0 / 720.0) * level_viewport.size.x
	print(level_viewport.size)

