extends CharacterBody2D

@onready var collision_shape_2d = $CollisionShape2D
@onready var i_frame_sprite = $IFrame
@onready var invul_shield = $InvulShield
@onready var animation_player = $AnimationPlayer
@onready var main_sprite = $AnimatedSprite2D
@onready var dash_sprite = $DashSprite


signal health_changed(old_health, new_health)
signal max_health_changed(old_maximum, new_maximum)
signal died
signal dash_changed(dash)
signal max_dash_changed(max_dash)

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

var fly_speed = 12000
var dash_increase = 12000
var speed_boost = 12000
var speed_boost_target = 200

var speed_boost_timer = null
var invul_timer = null

var can_take_damage: bool:
	get:
		return !collision_shape_2d.disabled
	set(value):
		collision_shape_2d.disabled = !value

var can_user_controll_vertical: bool = true

const I_FRAME_DURATION = 0.5

func _ready():
	i_frame_timer = Timer.new()
	i_frame_timer.timeout.connect(_on_i_frame_timeout)
	add_child(i_frame_timer)
	target = position
	speed_boost_timer = Timer.new()
	speed_boost_timer.one_shot = true
	add_child(speed_boost_timer)
	invul_timer = Timer.new()
	invul_timer.timeout.connect(_on_invul_timeout)
	invul_timer.one_shot = true
	add_child(invul_timer)

func _process(delta):
	if not _active:
		return
	var direction = Vector2()

	direction += Input.get_vector("fly1_left", "fly1_right", "fly1_up", "fly1_down")
	if !can_user_controll_vertical:
		direction.x = -1.0
	var speed = fly_speed
	var target_speed = 300
	if Input.is_action_just_pressed("fly1_dash"):
		animation_player.play("dash")
		dash_sprite.visible = true
		main_sprite.visible = false
	if Input.is_action_just_released("fly1_dash"):
		dash_sprite.visible = false
		main_sprite.visible = true
	if Input.is_action_pressed("fly1_dash"):
		if dash_time > 0.0:
			dash_time -= delta
			dash_changed.emit(dash_time)
			speed += dash_increase
			target_speed += 100
		if dash_time <= 0.0:
			dash_sprite.visible = false
			main_sprite.visible = true
	else:
		if dash_time < dash_time_max:
			dash_time += delta*0.5
			dash_changed.emit(dash_time)
	
	
	#velocity = Vector2.ZERO
	inertia /= 1.1
	velocity = Vector2.ZERO + inertia
	
	if speed_boost_timer.time_left > 0:
		speed += speed_boost
		target_speed += speed_boost_target
	
	direction = direction.normalized()
	target += direction * target_speed * delta * 1/(direction.length()/250+1)
	
	
	direction = target - position
	
	
	if direction.length() > 2:
		direction = direction.normalized()
	
		velocity += direction * speed * delta
		rotation = direction.angle()
	i_frame_sprite.rotation = -rotation
	invul_shield.rotation = -rotation
	move_and_slide()
	
	if target_marker != null:
		#target_marker.position = (position - target) * 4
		var distance_from_player = position.distance_to(target)
		if distance_from_player > 100:
			var direction_reduced = (target - position).normalized()
			target = position + direction_reduced * 100
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

func heal(value):
	set_health(min(_health+value, _max_health))

func become_invulnerable(value):
	invul_timer.start(value)
	invul_shield.visible = true

func boost_speed(value):
	speed_boost_timer.start(value)

func take_damage(value):
	if not i_frame_timer.is_stopped():
		return
  
	if not invul_timer.is_stopped():
		return
  
	set_health(_health-value)
	i_frame_timer.start(I_FRAME_DURATION)
	i_frame_sprite.visible = true
	target = position

func increase_dash_time(value):
	dash_time_max += value
	dash_time += value
	max_dash_changed.emit(dash_time_max)
	dash_changed.emit(dash_time)

func _on_i_frame_timeout():
	i_frame_timer.stop()
	i_frame_sprite.visible = false

func _on_invul_timeout():
	invul_shield.visible = false

func set_active(active):
	_active = active
	visible = active
	if active:
		set_health(_max_health)
	collision_shape_2d.disabled = not active
