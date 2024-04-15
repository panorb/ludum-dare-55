extends Node2D


@onready var animation_player = $AnimationPlayer
@onready var logo_fly := %LogoFly

signal win_animation_finisched

var spawned = false
var won = false

func _ready():
	visible = false
	logo_fly.visible = false
	animation_player.animation_finished.connect(on_win_animation_finisched)

func play_spawn_animation():
	if !spawned:
		spawned = true
		visible = true
		animation_player.play("spawn")

func play_win_animation():
	if !won:
		won = true
		logo_fly.visible = true
		animation_player.play("win")

func on_win_animation_finisched(anim_name: StringName):
	if anim_name == 'win':
		win_animation_finisched.emit()
