extends Node2D

var viewport_size = Vector2.ONE
var size
#@onready var player := %EntityContainer/Player
@onready var entities := %EntityContainer
@onready var indicator := %Indicator
@onready var vertical_boundaries := %VerticalBoundaries

var total_level_width := 0.0

const BOOK = preload("res://game/entities/book.tscn")

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
	book._create_copies(total_level_width)
	book.connect_signals(self)
	entities.add_child(book)

func move_indicator(pos):
	indicator.position = pos
