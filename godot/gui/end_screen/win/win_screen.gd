class_name WinScreen

extends Node

@onready var restart_info := %RestartInfo

signal show_main_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.tween_property($TitleTop, "position", Vector2($TitleTop.position.x, $TitleTop.position.y + 2), 2.0)
	tween.tween_property($TitleTop, "position", Vector2($TitleTop.position.x, $TitleTop.position.y - 2), 2.0)
	tween.set_loops()

	tween = create_tween()
	tween.tween_property($TitleBottom, "position", Vector2($TitleBottom.position.x, $TitleBottom.position.y - 2), 2.0)
	tween.tween_property($TitleBottom, "position", Vector2($TitleBottom.position.x, $TitleBottom.position.y + 2), 2.0)
	tween.set_loops()
	
	var restart_info_tween_transparency := Color(Color.WHITE, 0.4)
	var restart_info_tween = create_tween()
	restart_info_tween.tween_property(restart_info, "modulate", restart_info_tween_transparency, 0.8)
	restart_info_tween.tween_property(restart_info, "modulate", Color.WHITE, 0.8)
	restart_info_tween.set_loops()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("restart_game"):
		show_main_menu.emit()
