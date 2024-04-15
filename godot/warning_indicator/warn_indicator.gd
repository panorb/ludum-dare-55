extends Sprite2D

var _blinking_speed := 0.0
var _blinking_in := 0.0

func _process(delta: float) -> void:
	if is_zero_approx(_blinking_speed):
		return
	
	_blinking_in -= delta
	if _blinking_in < 0:
		_blinking_in = _blinking_speed
		visible = !visible

func update_blinking_speed(distance: float) -> void:
	if is_zero_approx(_blinking_speed) && distance > 0:
		visible = true
	_blinking_speed = 0.5
	
	var max_distance := 1000
	var pct: float = (1 - min(1, distance / max_distance))
	_blinking_speed = max(0.1, 0.2 * (1 - pct ** min(1.5, max_distance)))
	scale = (0.3 + (pct / 2.0)) * Vector2.ONE
	print(round(distance), " ", pct, " ", scale)

func disable() -> void:
	_blinking_speed = 0
	visible = false
