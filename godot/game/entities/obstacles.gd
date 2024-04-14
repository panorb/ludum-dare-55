extends Node

#signal collision(obstacle)
#
#const BOOK = preload("res://game/obstacles/book.tscn")
#
#var obstacles
#
#@onready var player = $"../Player"
#
## Called when the node enters the scene tree for the first time.
#func _ready():
	#obstacles = []
#
## spawns a book
#func _add_book(x, y, speed_x=0.0, speed_y=0.0):
	#var book = BOOK.instantiate()
	#book.init(x, y, speed_x, speed_y)
	#book.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	#book.connect("collision", _child_collision)
	#add_child(book)
	#obstacles.append(book)
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	##placeholder code to spam books
	#if randi()%10 == 0:
		#var dir = (randi() % 2)
		#if dir == 0:
			#dir = -1
		#_add_book(dir*700+640, randi()%500, -dir*(300+randi()%200), randi() % 200-200)
#
## emits a signal if the player collides with an obstacle
#func _child_collision(body, obstacle):
	#if body == player:
		#collision.emit(obstacle, 0, 0)


