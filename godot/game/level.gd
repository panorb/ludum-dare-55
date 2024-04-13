extends Node2D

var viewport_size = Vector2.ZERO
@onready var player := $Player

func _update(delta: float):
	pass

func get_player_position():
	var half_length = viewport_size.x/2
	var px_center = position.x + half_length
	var px_offset = player.position.x - px_center
	var relative_offset = px_offset / half_length
	return relative_offset
	# return 

func move_view(move_x: float):
	position.x -= move_x * 10.0
