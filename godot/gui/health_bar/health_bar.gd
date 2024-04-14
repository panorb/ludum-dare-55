extends Control

var MAX_HEALTH = 1000
@onready var bar = $"AspectRatioContainer/FrameMask/Bar"
@onready var frame = $AspectRatioContainer/Frame

var _max_health
var _health
var _display_health
var _player

# Called when the node enters the scene tree for the first time.
func _ready():
	_max_health = MAX_HEALTH
	_health = _max_health
	_display_health = 100
	#var player = get_tree().get_nodes_in_group("player")[0]
	#
	#print(player)

# resets the health bar to its maximum. Providing a value allows setting the maximum directly
func reset(value=null):
	if value == null:
		_max_health = MAX_HEALTH
	else:
		_max_health = value
	set_health(_max_health)


# sets the maximum healthbar value
func set_max_health(value):
	_max_health = value


# sets the current health directly
func set_health(value):
	_health = value
	_display_health = int(ceil(100.0*float(_health)/float(_max_health)))
	bar.position.x = _display_health-100


# reduced the health by the given amount, defaulting to 1
func take_damage(amount=1):
	set_health(_health - amount)

func set_player(player):
	if player == null:
		visible = false
		return
	visible = true
	_player = player
	set_health(player._health)
	set_max_health(player._max_health)
	_player.health_changed.connect(on_player_health_changed)
	_player.max_health_changed.connect(on_player_max_health_changed)

func on_player_health_changed(old_value, new_value):
	set_health(new_value)

func on_player_max_health_changed(old_value, new_value):
	set_max_health(new_value)
