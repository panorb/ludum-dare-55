extends Node2D

const COLOR := Color.RED
var draw_method: Callable
var duration: float
var remaining: float
var blinking_speed: float
var blinking_in: float
var is_displayed: bool
var customs := {}

func _process(delta: float) -> void:
	if remaining < 0:
		return
	blinking_in -= delta
	remaining -= delta
	if remaining < 0:
		is_displayed = false
		queue_redraw()
	elif blinking_in < 0:
		blinking_in = blinking_speed
		is_displayed = !is_displayed
		_recalc_blinking_speed()
		queue_redraw()

func _draw() -> void:
	if is_displayed:
		draw_method.call()

func warn_about_laser(seconds: float):
	_prepare_generic_properties(seconds)
	draw_method = func():
		draw_circle(Vector2(640, 360), 100, COLOR)

func warn_about_full(seconds: float):
	_prepare_generic_properties(seconds)
	draw_method = func():
		draw_rect(Rect2(0, 0, 1280, 720), COLOR, false, 10)

func _prepare_generic_properties(seconds: float) -> void:
	duration = seconds
	remaining = seconds
	blinking_in = blinking_speed
	is_displayed = true
	_recalc_blinking_speed()

func _recalc_blinking_speed() -> void:
	var passed := duration - remaining
	blinking_speed = max(0.1, 0.2 * (1 - (passed / duration) ** min(1.5, duration)))
