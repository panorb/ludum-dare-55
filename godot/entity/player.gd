extends Node2D

signal health_changed(old_health, new_health)
signal max_health_changed(old_maximum, new_maximum)
signal died

var _active = false
var _health = 1000
var _max_health = 1000

func _process(delta):
	if not _active:
		return
	var direction = Vector2()
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	if direction.length() > 0:
		direction = direction.normalized()
		position += direction * 200 * delta
		# when to the left, the sprite is flipped
		if direction.x < 0:
			$Sprite2D.flip_v = true
		else:
			$Sprite2D.flip_v = false

		rotation = direction.angle()

func set_max_health(value):
	var old_value = _max_health
	_max_health = value
	max_health_changed.emit(old_value, value)

func set_health(value):
	var old_value = _health
	_health = value
	health_changed.emit(old_value, value)
	if _health <= 0 and old_value > 0:
		died.emit()
		set_active(false)

func take_damage(value):
	set_health(_health-value)

func set_active(active):
	_active = active
	visible = active
	if active:
		set_health(_max_health)
