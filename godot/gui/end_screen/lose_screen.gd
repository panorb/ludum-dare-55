class_name LoseScreen

extends Control

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

	tween = create_tween()
	tween.tween_property($Halo, "position", Vector2($Wings.position.x, $Wings.position.y - 8), 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property($Halo, "position", Vector2($Wings.position.x, $Wings.position.y + 8), 2.0).set_trans(Tween.TRANS_SINE)
	tween.set_loops()
