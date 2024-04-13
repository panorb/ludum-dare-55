extends Node2D

var viewport_size = Vector2.ONE
@onready var player := %Player
@onready var bullets := %BulletContainer

func _update(delta: float):
	pass

func move_player_back_to_center():
	var center = Vector2(viewport_size / 2)
	var offset = player.position - center
	print("offset: ", offset)

	if abs(offset.x) > 100:
		player.position.x += offset.x * -0.01
		bullets.position.x += offset.x * -0.01
	else:
		offset = Vector2.ZERO

	return offset.x

func move_view(move_x: float):
	position.x -= move_x
