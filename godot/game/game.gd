extends Control

@onready var level_viewport := %LevelViewport
@onready var environment_viewport := %EnvironmentViewport
@onready var environment := %Environment
@onready var level := %Level

@onready var health_bar_p1 = $UIOverlay/Grid/Player1/HealthBar
@onready var health_bar_p2 = $UIOverlay/Grid/Player2/HealthBar


var game_timer

const LEVEL_VIEW_MOVEMENT_SCALE = 1.45
const ENVIRONMENT_CAMERA_MOVEMENT_SCALE = 0.0005

func _process(delta):
	var x_offset = level.get_player_offset(delta)
	if abs(x_offset) > 45.0:
		level.move_view(x_offset * -delta * LEVEL_VIEW_MOVEMENT_SCALE)
		environment.move_view(x_offset * delta * ENVIRONMENT_CAMERA_MOVEMENT_SCALE)
	%CameraPosLabel.text = "Camera: " + str(environment.get_camera_position())
	%CalculatedCameraLabel.text = "Calc. Camera: " + str(get_environment_camera_pos_from_level_x(level.get_level_view_x()))
	%LevelViewLabel.text = "Level: " + str(level.get_level_view_x())
	%CalculatedLevelViewLabel.text = "Calc. Level: " + str(get_level_x_from_environment_camera_pos(environment.get_camera_position()))
	
	if randi()%30 == 0:
		var player_pos = get_tree().get_nodes_in_group("player")[0].position
		var dir = (randi() % 2)
		var y = randi()%180
		var warning_pos = Vector2(dir*300, y)
		if dir == 0:
			dir = -1
		var x = (dir*300+player_pos.x)
		var speed_x = -dir*(100+randi()%100)
		var speed_y = randi() % 100-100
		level._add_book(x, y, speed_x, speed_y)

func get_level_x_from_environment_camera_pos(camera_pos: float):
	return -(camera_pos / ENVIRONMENT_CAMERA_MOVEMENT_SCALE) * LEVEL_VIEW_MOVEMENT_SCALE

func get_environment_camera_pos_from_level_x(level_x: float):
	return -(level_x / LEVEL_VIEW_MOVEMENT_SCALE) * ENVIRONMENT_CAMERA_MOVEMENT_SCALE

func _ready():
	_on_window_size_changed()
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	level.viewport_size = level_viewport.size
	level.set_world_size(Vector2(abs(get_level_x_from_environment_camera_pos(1.0)), 180))
	var players = get_tree().get_nodes_in_group("player")
	var health_bars = [health_bar_p1, health_bar_p2]
	var player_count = 1
	for i in range(player_count):
		print("Activating player "+str(i+1))
		players[i].set_active(true)
		health_bars[i].set_player(players[i])
		players[i].set_health(players[i]._max_health)
	for i in range(player_count, len(health_bars)):
		print("Deactivating player "+str(i+1))
		players[i].set_active(false)
		health_bars[i].set_player(null)
	for player in players:
		player.died.connect(_on_player_death)
	game_timer = Timer.new()
	add_child(game_timer)
	game_timer.start(60)
	game_timer.connect("timeout", on_game_timeout)

func _on_window_size_changed():
	environment_viewport.size = get_tree().get_root().size

func on_game_timeout():
	print("you win")
	game_timer.queue_free()
	get_tree().change_scene_to_file("res://gui/end_screen/win_screen.tscn")

func _on_player_death():
	var player_alive_count = 0
	for player in get_tree().get_nodes_in_group("player"):
		if player._active:
			player_alive_count += 1
	if player_alive_count <= 0:
		game_timer.stop()
		print("you lose")
		
		get_tree().change_scene_to_file("res://gui/end_screen/lose_screen.tscn")

func _on_level_texture_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			print(event.position)
