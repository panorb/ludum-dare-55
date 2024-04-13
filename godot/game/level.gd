extends Node2D

var viewport_size = Vector2.ONE
@onready var player := $Player
@onready var bullets := $Bullets

func _update(delta: float):
	pass

func get_player_position():
	var center = Vector2(viewport_size / 2)
	var offset = player.position - center
	print("offset: ", offset)

	if abs(offset.x) > 100:
		player.position.x += offset.x * -0.01
		bullets.position.x += offset.x * -0.01

func move_view(move_x: float):
	position.x -= move_x
