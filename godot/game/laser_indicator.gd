extends Node2D
class_name LaserIndicator


@onready var indicator = %Indicator
@onready var laser_radius_indicator = %TextureRadiusIndicator

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	indicator.rotate(delta * 1.0)
	scale = Vector2.ONE * (sin(Time.get_ticks_msec() / 1000.0) * 0.5 + 1.0)
