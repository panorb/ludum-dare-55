extends CharacterBody2D

@onready var collision_shape_2d = $CollisionShape2D

signal health_changed(old_health, new_health)
signal max_health_changed(old_maximum, new_maximum)
signal died

var _active = false
var _health = 1000
var _max_health = 1000
var inertia = Vector2.ZERO
var i_frame_timer

const I_FRAME_DURATION = 0.5

func _ready():
	i_frame_timer = Timer.new()
	i_frame_timer.timeout.connect(_on_i_frame_timeout)
	add_child(i_frame_timer)

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
	
	#velocity = Vector2.ZERO
	inertia /= 1.1
	velocity = Vector2.ZERO + inertia
	
	if direction.length() > 0:
		direction = direction.normalized()
		#position += direction * 200 * delta
		
		velocity += direction * 200# * delta
		# when to the left, the sprite is flipped
		if direction.x < 0:
			$Sprite2D.flip_v = true
		else:
			$Sprite2D.flip_v = false

		rotation = direction.angle()
	move_and_slide()

func set_max_health(value):
	var old_value = _max_health
	_max_health = value
	max_health_changed.emit(old_value, value)

func set_health(value):
	var old_value = _health
	_health = value
	health_changed.emit(old_value, value)
	print(self.name+" "+str(old_value)+" -> "+str(_health))
	if _health <= 0 and old_value > 0:
		set_active(false)
		died.emit()
		print("died emitted")

func take_damage(value):
	print("ouchy")
	print(i_frame_timer.time_left)
	if not i_frame_timer.is_stopped():
		return
	set_health(_health-value)
	i_frame_timer.start(I_FRAME_DURATION)

func _on_i_frame_timeout():
	i_frame_timer.stop()

func set_active(active):
	_active = active
	visible = active
	if active:
		set_health(_max_health)
	collision_shape_2d.disabled = not active
