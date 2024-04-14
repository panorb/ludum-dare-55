extends Node3D


@onready var camera_origin: Node3D = get_node("%CameraOrigin")
@onready var camera: Camera3D = get_node("%Camera3D")
@onready var camera_focus: Marker3D = get_node("%CameraFocus")
@onready var camera_follow: PathFollow3D = %PathFollow3D
@onready var laser_origin = %LaserOrigin
# TODO: eventually this needs to be removed
@onready var laser = %Laser

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_camera_position():
	return camera_origin.rotation_degrees.y / 360.0

var pos = 0.0


func move_view(move_x: float):
	var new_pos = get_camera_position() + move_x	
	rotate_cam_to_pos(new_pos * 360.0)

func _process(delta):
	move_camera_forward(delta)
	camera.look_at(camera_focus.global_transform.origin, Vector3(0, 1, 0))
	#pos += delta * 100

	# rotate_cam_to_pos(pos)
	if pos > 360:
		pos = 0

# angle in rads
func rotate_cam_to_pos(angle: float):
	camera_origin.rotation = Vector3(0,deg_to_rad(fmod(angle, 360.0)),0)


func move_camera_forward(delta:float):
	return
	camera_follow.progress_ratio += delta * 0.025
	if camera_follow.progress_ratio >= 1:
		camera_follow.progress_ratio = 1
