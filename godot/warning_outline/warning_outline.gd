extends Node2D

const COLOR := Color.RED
var _draw_method: Callable
var _duration: float
var _remaining: float
var _blinking_speed: float
var _blinking_in: float
var _is_displayed: bool

func _process(delta: float) -> void:
	if _remaining < 0:
		return
	_blinking_in -= delta
	_remaining -= delta
	if _remaining < 0:
		_is_displayed = false
		queue_redraw()
	elif _blinking_in < 0:
		_blinking_in = _blinking_speed
		_is_displayed = !_is_displayed
		_recalc_blinking_speed()
		queue_redraw()

func _draw() -> void:
	if _is_displayed:
		_dra_method.call()

func warn_about_laser(seconds: float):
	_prepare_generic_properties(seconds)
	_draw_method = func():
		draw_circle(Vector2(640, 360), 100, COLOR)

func warn_about_full(seconds: float):
	_prepare_generic_properties(seconds)
	_draw_method = func():
		draw_rect(Rect2(0, 0, 1280, 720), COLOR, false, 10)

func warn_with_exclamation_mark(seconds: float, pos: Vector2):
	_prepare_generic_properties(seconds)
	_draw_method = func():
		var radius_x := 30
		var radius_y := 90
		var center := Vector2(pos.x + radius_x, pos.y + radius_y)
		var radius_point := 25
		var point_count := 100

		var points := []
		for i in range(point_count):
			var angle = 2 * PI * i / point_count
			var x = center.x + radius_x * cos(angle)
			var y = center.y + radius_y * sin(angle)
			points.append(Vector2(x, y))

		draw_colored_polygon(points, COLOR)
		draw_circle(Vector2(center.x, center.y + radius_y + radius_point + 15), radius_point, COLOR)

func _prepare_generic_properties(seconds: float) -> void:
	_duration = seconds
	_remaining = seconds
	_blinking_in = _blinking_speed
	_is_displayed = true
	_recalc_blinking_speed()

func _recalc_blinking_speed() -> void:
	var passed := _duration - _remaining
	_blinking_speed = max(0.1, 0.2 * (1 - (passed / _duration) ** min(1.5, _duration)))
