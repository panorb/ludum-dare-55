extends Node2D


@onready var animation_player = $AnimationPlayer

func play_spawn_animation():
	pass

func play_win_animation():
	animation_player.play("win")
