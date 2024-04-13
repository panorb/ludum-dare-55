extends Node3D


@onready var camera_origin: Node3D = get_node("%CameraOrigin")
@onready var camera: Camera3D = get_node("%Camera3D")
@onready var camera_focus: Marker3D = get_node("%CameraFocus")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


var pos = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pos += delta * 100

	rotate_cam_to_pos(pos)
	if pos > 360:
		pos = 0

# angle in rads
func rotate_cam_to_pos(angle: float):
	camera_origin.rotation = Vector3(0,deg_to_rad(angle),0)

	camera.look_at(camera_focus.global_transform.origin, Vector3(0, 1, 0))

