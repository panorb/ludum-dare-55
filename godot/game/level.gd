extends Node2D

var viewport_size = Vector2.ONE
@onready var player := %Player
@onready var bullets := %BulletContainer


func get_player_offset(delta: float):
	var center = Vector2(viewport_size / 2)
	var offset = player.position - center

	return offset.x

func move_view(move_x: float):
	player.position.x += move_x
	bullets.position.x += move_x

func get_level_view_x():
	return bullets.position.x
