class_name Game

extends Control

@onready var level_viewport := %LevelViewport
@onready var environment_viewport := %EnvironmentTexture/EnvironmentViewport
@onready var environment_texture: TextureRect = %EnvironmentTexture
@onready var level_texture: TextureRect = %LevelTexture
@onready var environment := %EnvironmentTexture/EnvironmentViewport/Environment
@onready var level := %Level
@onready var main_theme_sound = %MainThemeSound
@onready var timer_label = %TimerLabel

@onready var health_bar_p1 = $UIOverlay/Grid/Player1/HealthBar
@onready var health_bar_p2 = $UIOverlay/Grid/Player2/HealthBar

@onready var post_processing_rect := $CanvasLayer/ColorRect

@onready var laser_scene: PackedScene = preload("res://effects/laser.tscn")
@onready var laser_indicator_scene: PackedScene = preload("res://game/laser_indicator.tscn")

@onready var death_timer := %DeathTimer

var game_end : bool = false

var game_timer: Timer
const max_game_time = 180.

const LEVEL_VIEW_MOVEMENT_SCALE = 0.9
const ENVIRONMENT_CAMERA_MOVEMENT_SCALE = 0.0005
const FREE_MOVEMENT_ZONE_WIDTH = 50

var delay = 0.0
var sec_since_last_magician_sfx = 0.0

signal show_lose_screen
signal show_win_screen


func _process(delta):
	var x_offset = level.get_player_offset()

	if abs(x_offset) > FREE_MOVEMENT_ZONE_WIDTH && !game_end:
		if x_offset > 0:
			x_offset -= FREE_MOVEMENT_ZONE_WIDTH
		else:
			x_offset += FREE_MOVEMENT_ZONE_WIDTH
		x_offset += x_offset
		environment.move_view(x_offset * delta * ENVIRONMENT_CAMERA_MOVEMENT_SCALE)
		level.move_view(x_offset * -delta * LEVEL_VIEW_MOVEMENT_SCALE)
	
	%CameraPosLabel.text = "Camera: " + str(environment.get_camera_position())
	%CalculatedCameraLabel.text = "Calc. Camera: " + str(get_environment_camera_pos_from_level_x(level.get_level_view_x()))
	%LevelViewLabel.text = "Level: " + str(level.get_level_view_x())
	%CalculatedLevelViewLabel.text = "Calc. Level: " + str(get_level_x_from_environment_camera_pos(environment.get_camera_position()))
	
	%Harbinger.update(level.viewport_size, get_level_position_from_normalized_screen_position(Vector2(0.5, 0.5)))

	# Calculcate und display left times
	var left_minutes : int = game_timer.time_left / 60
	var left_seconds : int = int(game_timer.time_left) % 60
	timer_label.text = "%d:%02d" % [left_minutes, left_seconds]
	
	sec_since_last_magician_sfx += delta
	if sec_since_last_magician_sfx > 5 && randi()%50 == 0:
		var sound: AudioStreamPlayer = %BoneRattleSound if randi()%2 == 0 else %WizardSounds
		if death_timer.is_stopped():
			sound.play()
		sec_since_last_magician_sfx = -sound.stream.get_length()

	var r = randi()%(450+int(game_timer.time_left*1.5))
	if game_timer.time_left < 9.0:
		r = 10
		level.kill_lasers()
	if r > 0 and r <= 7:
		var player_pos = get_tree().get_nodes_in_group("player")[0].position
		var dir = (randi() % 2)
		var y = randi()%180
		if dir == 0:
			dir = -1
		#var x = (dir*600+player_pos.x+level.get_player_offset())
		var x = player_pos.x-level.get_player_offset()+dir*350
		var speed_x = -dir*(100+randi()%200)
		x -= speed_x/2
		var speed_y = randi() % 200-200
		level._add_book(x, y, speed_x, speed_y)
		var bookSound: AudioStreamPlayer = %BookSpawnSound
		bookSound.play()
		environment.feedback("spawn_object")
	if r == 8 and level.get_laser_count() < 4:
		var player_pos = get_tree().get_nodes_in_group("player")[0].position
		var laser_pos = Vector2(randi()%1280-640, randi()%720-360)
		if (player_pos-laser_pos).length() > 200:
			spawn_laser(player_pos+laser_pos)
			var impactSound: AudioStreamPlayer = %LaserImpactSound
			impactSound.play()
	
	environment.set_game_progress_ratio(1.-game_timer.time_left/max_game_time)
	
	if r == 0:
		var player_pos = get_tree().get_nodes_in_group("player")[0].position
		var dir = (randi() % 2)
		var y = randi()%180
		if dir == 0:
			dir = -1
		#var x = (dir*600+player_pos.x+level.get_player_offset())
		var x = player_pos.x-level.get_player_offset()+dir*350
		var speed_x = -dir*(50+randi()%150)
		var speed_y = randi() % 100-100
		var type = randi()%10
		if type == 0:
			level._add_powerup(x, y, speed_x, speed_y, level.PowerUps.HEALTH_BOOST)
		elif type == 1:
			level._add_powerup(x, y, speed_x, speed_y, level.PowerUps.DASH_INCREASE)
		elif type == 2:
			level._add_powerup(x, y, speed_x, speed_y, level.PowerUps.SPEED_BOOST)
		elif type == 3:
			level._add_powerup(x, y, speed_x, speed_y, level.PowerUps.INVULNERABILITY)
		else:
			level._add_powerup(x, y, speed_x, speed_y, level.PowerUps.HEAL)

func get_level_x_from_environment_camera_pos(camera_pos: float):
	return -(camera_pos / ENVIRONMENT_CAMERA_MOVEMENT_SCALE) * LEVEL_VIEW_MOVEMENT_SCALE

func get_environment_camera_pos_from_level_x(level_x: float):
	return -(level_x / LEVEL_VIEW_MOVEMENT_SCALE) * ENVIRONMENT_CAMERA_MOVEMENT_SCALE


func get_level_position_from_normalized_screen_position(scaled_pos: Vector2):
	var level_x = -level.get_level_view_x() + (scaled_pos.x * level_viewport.size.x)
	var level_y = scaled_pos.y * level_viewport.size.y
	return Vector2(level_x, level_y)

func get_level_position_from_screen_pixel_coords(pixel_coords : Vector2):
	var scaled_pos = pixel_coords / get_viewport_rect().size
	return get_level_position_from_normalized_screen_position(scaled_pos)

func _ready():
	#_on_window_size_changed()
	#get_tree().get_root().size_changed.connect(_on_window_size_changed)
	level.viewport_size = level_viewport.size
	level.total_level_width = abs(get_level_x_from_environment_camera_pos(1.0))
	%TotalLevelWidthLabel.text = "Total level width: " + str(get_level_x_from_environment_camera_pos(1.0))

	var players = get_tree().get_nodes_in_group("player")
	var health_bars = [health_bar_p1, health_bar_p2]
	var player_count = 1

	environment.set_game_progress_ratio(0.)

	for i in range(player_count):
		players[i].set_active(true)
		health_bars[i].set_player(players[i])
		players[i].set_health(players[i]._max_health)

	for i in range(player_count, len(health_bars)):
		players[i].set_active(false)
		health_bars[i].set_player(null)

	for player in players:
		player.died.connect(_on_player_death)

	game_timer = Timer.new()
	game_timer.one_shot = true
	add_child(game_timer)

	game_timer.start(max_game_time)
	game_timer.timeout.connect(on_game_timeout)
	death_timer.timeout.connect(_on_game_end)

	for i in range(player_count):
		players[i].health_changed.connect(environment.on_player_health_changed)
		players[i].health_changed.connect(music_switcher)
	environment.uniform_changed.connect(on_post_processing_uniform_changed)

	environment.win_finisched.connect(_on_win_finisched)

func initialize_laser(laser:Node3D, indicator: Node2D):
	laser.laser_target = indicator
	laser.environment_viewport = environment_viewport
	laser.level_viewport = level_viewport
	laser.rotation_degrees = Vector3(14.4, 180, -75.6)
	laser.scale = Vector3(0.02, 0.02, 1)

func spawn_laser(game_coords: Vector2):
	var laser = laser_scene.instantiate()
	var indicator = laser_indicator_scene.instantiate()

	environment.laser_origin.add_child(laser)
	initialize_laser(laser, indicator)

	level.laser_target_container.add_child(indicator)
	indicator.position = game_coords

func on_game_timeout():
	game_end = true
	get_tree().get_nodes_in_group("player").all(func(player): player.can_take_damage = false)
	get_tree().get_nodes_in_group("player").all(func(player): player.can_user_controll_vertical = false)

	environment.win()

func music_switcher(_old_health, new_health):
	if new_health < 200 && %MainThemeSound.playing:
		%MainThemeSound.stop()
		%ThreatensToLoseSound.play()
	elif new_health <= 0:
		%MainThemeSound.stop()
		%ThreatensToLoseSound.stop()

func _on_player_death():
	game_timer.paused = true
	$FlyDeathSound.play()
	death_timer.start()

func _on_game_end():
	show_lose_screen.emit()

func _on_window_size_changed():
	environment_viewport.size = get_tree().get_root().size

func on_post_processing_uniform_changed(name: String, value: Variant):
	post_processing_rect.material.set_shader_parameter(name,value)

func _on_win_finisched():
	show_win_screen.emit()
