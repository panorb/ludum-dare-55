extends Node2D

var viewport_size = Vector2.ONE
var size
#@onready var player := %EntityContainer/Player
@onready var entities := %EntityContainer
@onready var top_border = $EntityContainer/VerticalBoundaries/TopBorder
@onready var bottom_border = $EntityContainer/VerticalBoundaries/BottomBorder

const BOOK = preload("res://game/entities/book.tscn")

func get_player_offset(delta: float):
	var center = Vector2(viewport_size / 2)
	var player_position = get_tree().get_nodes_in_group("player")[0].position
	var offset = entities.position + player_position - center

	return offset.x

func move_view(move_x: float):
	entities.position.x += move_x

func get_level_view_x():
	return entities.position.x

func _add_book(x, y, speed_x=0.0, speed_y=0.0):
	var book = BOOK.instantiate()
	book.init(x, y, speed_x, speed_y)
	book.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	book.connect_signals(self)
	entities.add_child(book)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	##placeholder code to spam books
	#if randi()%30 == 0:
		#var player_pos = get_tree().get_nodes_in_group("player")[0].position
		#var dir = (randi() % 2)
		#if dir == 0:
			#dir = -1
		#_add_book((dir*300+player_pos.x), randi()%180, -dir*(100+randi()%100), randi() % 100-100)
	pass

func set_world_size(new_size):
	size = new_size
	bottom_border.position.y = new_size.y
	bottom_border.shape.a = bottom_border.position
	bottom_border.shape.b = bottom_border.position
	bottom_border.shape.b.x = bottom_border.position.x+new_size.x
	top_border.shape.a = top_border.position
	top_border.shape.b = top_border.position
	top_border.shape.b.x = top_border.position.x+new_size.x
	
	for player in get_tree().get_nodes_in_group("player"):
		if player.position.y >= new_size.y:
			player.position.y = new_size.y-1
