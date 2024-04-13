extends Control

@onready var level_viewport := %LevelViewport
@onready var environment_viewport := %EnvironmentViewport
@onready var environment := %Environment
@onready var level := %Level


func _process(delta):
	level.viewport_size = level_viewport.size

	var x_offset = level.move_player_back_to_center()

	print("level position:", level.position)
	environment.move_view(x_offset * 0.0005)



func _input(event):
	pass
	#if event is InputEventMouseButton:
	#	if event.pressed:
	#		print(level_viewport.get_mouse_position())

func _ready():
	_on_window_size_changed()
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	level.viewport_size = level_viewport.size
	

func _on_window_size_changed():
	environment_viewport.size = get_tree().get_root().size


func _on_level_texture_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print(event.position)
