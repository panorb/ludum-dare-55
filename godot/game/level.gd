extends Node2D

var viewport_size := Vector2.ONE
var size
#@onready var player := %EntityContainer/Player
@onready var entities := %EntityContainer
@onready var laser_target_container := %LaserTargetContainer
@onready var vertical_boundaries := %VerticalBoundaries
@onready var player = %Player
@onready var player_2 = %Player2
@onready var target_marker_p_1 = %TargetMarkerP1
@onready var target_marker_p_2 = %TargetMarkerP2

var total_level_width := 0.0

const BOOK = preload("res://game/entities/book.tscn")
const POWERUP_HEAL = preload("res://game/entities/powerup_heal.tscn")
const POWERUP_HEALTH_BOOST = preload("res://game/entities/powerup_health_boost.tscn")
const POWERUP_DASH_INCREASE = preload("res://game/entities/powerup_dash_boost.tscn")
const POWERUP_SPEED_BOOST = preload("res://game/entities/powerup_speed_boost.tscn")
const POWERUP_INVULNERABILITY = preload("res://game/entities/powerup_invulnerability.tscn")
const PAGE = preload("res://game/entities/page.tscn")

enum PowerUps {HEAL, HEALTH_BOOST, DASH_INCREASE, SPEED_BOOST, INVULNERABILITY}

func _ready():
	player.target_marker = target_marker_p_1
	player_2.target_marker = target_marker_p_2

func _process(delta):
	if vertical_boundaries:
		vertical_boundaries.position.x = %Player.position.x - viewport_size.x

func get_player_offset():
	var center = Vector2(viewport_size / 2)
	var player_position = get_tree().get_nodes_in_group("player")[0].position
	var offset = entities.position + player_position - center

	return offset.x

func move_view(move_x: float):
	# entities.position.x = entities.position.x + move_x
	entities.position.x = entities.position.x + move_x

func get_level_view_x():
	return entities.position.x

func _add_book(x, y, speed_x=0.0, speed_y=0.0):
	var book = BOOK.instantiate()
	book.init(x, y, speed_x, speed_y)
	book.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	#book._create_copies(total_level_width)
	book.connect_signals(self)
	entities.add_child(book)

func _add_powerup(x, y, speed_x, speed_y, type=PowerUps.HEAL):
	var powerup = null
	if type == PowerUps.HEALTH_BOOST:
		powerup = POWERUP_HEALTH_BOOST.instantiate()
	elif type == PowerUps.DASH_INCREASE:
		powerup = POWERUP_DASH_INCREASE.instantiate()
	elif type == PowerUps.SPEED_BOOST:
		powerup = POWERUP_SPEED_BOOST.instantiate()
	elif type == PowerUps.INVULNERABILITY:
		powerup = POWERUP_INVULNERABILITY.instantiate()
	else:
		powerup = POWERUP_HEAL.instantiate()
	powerup.init(x, y, speed_x, speed_y)
	powerup.connect_signals(self)
	entities.add_child(powerup)

func get_laser_count():
	return laser_target_container.get_child_count()

func kill_lasers():
	for laser in laser_target_container.get_children():
		laser_target_container.remove_child(laser)
		laser.queue_free() 

func page_spawn(book):
	var page = PAGE.instantiate()
	page.position = book.position
	page.position += (Vector2(49.0, 86.0)/4).rotated(book.rotation)
	page.rotation = book.rotation
	page.speed = book.speed
	entities.add_child(page)
