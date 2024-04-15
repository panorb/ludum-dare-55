extends Entity
class_name LaserIndicator


@onready var indicator = %Indicator
@onready var laser_radius_indicator = %TextureRadiusIndicator

enum {STATE_IDLE, STATE_FOLLOWING, STATE_DYING}

var current_state = STATE_FOLLOWING
var state_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	damage = 300
	change_state(STATE_FOLLOWING)
	super()

var lifetime = 25.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if lifetime <= 5.0 and current_state != STATE_DYING:
		var tween : Tween = create_tween()
		tween.tween_property(indicator, "self_modulate", Color(1.0, 1.0, 1.0, 0.7), 0.2)
		tween.tween_property(indicator, "self_modulate", Color(1.0, 1.0, 1.0, 0.9), 0.2)
		# tween.tween_property(self, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5).from_current()
		tween.set_loops()
		change_state(STATE_DYING)
	
	if lifetime <= 0.0:
		queue_free()
	indicator.rotate(delta * 1.0)
	scale = Vector2.ONE * (sin(Time.get_ticks_msec() / 1000.0) * 0.5 + 1.0)
	
	handle_current_state(delta)
	
	lifetime -= delta
	state_time += delta

func change_state(new_state):
	state_time = 0.0
	current_state = new_state

var last_direction := Vector2.ZERO

func handle_current_state(delta):
	if current_state == STATE_FOLLOWING:
		last_direction = (player.position - position).normalized()
		position = position + (delta * last_direction * 180)
		
		if state_time >= 4.0:
			change_state(STATE_IDLE)
	elif current_state == STATE_IDLE:
		position = position + (delta * last_direction * 160)
		
		if state_time >= 3.5:
			change_state(STATE_FOLLOWING)
	elif current_state == STATE_DYING:
		position = position + (delta * last_direction * 160)

func on_player_collision(player):
	player.take_damage(damage)
	player.inertia += (player.position-position).normalized()*800
