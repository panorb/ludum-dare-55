extends Control

@onready var swat: TextureRect = $Swat
@onready var wand: TextureRect = $Wand
var start_animation_in := 1.

func _process(delta: float) -> void:
	if start_animation_in > 0:
		start_animation_in -= delta
		return
	var step := 700 * delta
	swat.position = Vector2(max(0, swat.position.x - step), max(0, swat.position.y - step))
	wand.position = Vector2(min(0, wand.position.x + step), max(0, wand.position.y - step))
