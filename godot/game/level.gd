extends Node2D

var viewport_size = Vector2.ONE
@onready var player := %Player
@onready var entities := %EntityContainer

const BOOK = preload("res://game/entities/book.tscn")

func get_player_offset(delta: float):
	var center = Vector2(viewport_size / 2)
	var offset = player.position - center

	return offset.x

func move_view(move_x: float):
	player.position.x += move_x
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
	#placeholder code to spam books
	if randi()%10 == 0:
		var dir = (randi() % 2)
		if dir == 0:
			dir = -1
		_add_book(dir*700+640, randi()%500, -dir*(300+randi()%200), randi() % 200-200)

func on_player_entity_collision(entity):
	pass

func _input(event):
	if event is InputEventMouseButton:
		var mouse_pos = event.position

		# get global coordinates on the near plane
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos)

		print(from)
		print(to)
