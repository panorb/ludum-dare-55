extends Control

@onready var level_viewport := %LevelViewport
@onready var environment_viewport := %EnvironmentViewport
@onready var environment := %Environment
@onready var level := %Level

var run_no = 0

func _process(delta):
	var player_pos = level.get_player_position()
	print(player_pos)
	if abs(player_pos) > 0.6 and run_no < 17:
		environment.move_view(player_pos)
		level.move_view(player_pos)
		run_no += 1

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
