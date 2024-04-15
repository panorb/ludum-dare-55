extends CharacterBody2D

@onready var collision_shape_2d = $CollisionShape2D

signal health_changed(old_health, new_health)
signal max_health_changed(old_maximum, new_maximum)
signal died

var _active = false
var _health = 1000
var _max_health = 1000
var inertia = Vector2.ZERO
var i_frame_timer = null
var target = Vector2.ZERO
var target_marker = null
var dashing = false
var dash_time = 3.0
var dash_time_max = 3.0

const I_FRAME_DURATION = 0.5

func _ready():
	i_frame_timer = Timer.new()
	i_frame_timer.timeout.connect(_on_i_frame_timeout)
	add_child(i_frame_timer)
	target = position

func _process(delta):
	if not _active:
		return
	var direction = Vector2()
	
	#if Input.is_action_pressed("fly1_right"):
		#direction.x += 1
	#if Input.is_action_pressed("fly1_left"):
		#direction.x -= 1
	#if Input.is_action_pressed("fly1_down"):
		#direction.y += 1
	#if Input.is_action_pressed("fly1_up"):
		#direction.y -= 1
	direction += Input.get_vector("fly1_left", "fly1_right", "fly1_up", "fly1_down")
	var speed = 200
	var target_speed = 300
	if Input.is_action_pressed("fly1_dash"):
		if dash_time > 0.0:
			dash_time -= delta
			speed += 200
			target_speed += 100
	else:
		if dash_time < dash_time_max:
			dash_time += delta*0.5
	
	
	#velocity = Vector2.ZERO
	inertia /= 1.1
	velocity = Vector2.ZERO + inertia
	
	direction = direction.normalized()
	target += direction * target_speed * delta * 1/(direction.length()/250+1)
	
	#if direction.length() > 0:
	
	#if not i_frame_timer.is_stopped():
	#	target = position
	
	direction = target - position
	
	
	if direction.length() > 2:
		direction = direction.normalized()
		#position += direction * 200 * delta
	
		velocity += direction * speed# * delta
		print(position, velocity, inertia, target)
		#velocity += direction * 1000# * delta
		# when to the left, the sprite is flipped
		#if direction.x < 0:
			#$AnimatedSprite2D.flip_v = true
		#else:
			#$AnimatedSprite2D.flip_v = false

	rotation = velocity.angle()+90
	move_and_slide()
	
	if target_marker != null:
		#target_marker.position = (position - target) * 4
		target_marker.position = target

func set_max_health(value):
	var old_value = _max_health
	_max_health = value
	max_health_changed.emit(old_value, value)

func set_health(value):
	var old_value = _health
	_health = value
	health_changed.emit(old_value, value)
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
	target = position

func _on_i_frame_timeout():
	i_frame_timer.stop()

func set_active(active):
	_active = active
	visible = active
	if active:
		set_health(_max_health)
	collision_shape_2d.disabled = not active
