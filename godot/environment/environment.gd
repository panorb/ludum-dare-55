extends Node3D

@onready var camera_origin: Node3D = get_node("%CameraOrigin")
@onready var camera: Camera3D = get_node("%Camera3D")
@onready var camera_focus: Marker3D = get_node("%CameraFocus")
@onready var camera_follow: PathFollow3D = %PathFollow3D
@onready var laser_origin = %LaserOrigin
# TODO: eventually this needs to be removed
@onready var pentagram: MeshInstance3D = $vfx/Pentagram
@onready var storm: MeshInstance3D = $vfx/Storm

signal uniform_changed

var game_progress = 0.
var pent_bright = 0.
var storm_timer = 0.
var storm_speed = 1.
var global_time = 0.
var damage_time = 0.
var health = 0.

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
	
	#effects
	global_time += delta
	storm_speed = 1+game_progress
	storm_timer += delta*storm_speed
	if pent_bright > 0:
		pent_bright -= delta*3.;
	if pent_bright < 0:
		pent_bright = 0
	
	if damage_time > 0:
		damage_time -= delta*3.;
	if damage_time < 0:
		damage_time = 0
	
	# set uniforms
	pentagram.material_override["shader_parameter/u_height"] = pent_bright
	storm.material_override["shader_parameter/u_stormOpacity"] = .25+.5*game_progress
	storm.material_override["shader_parameter/u_stormSpeed"] = storm_timer
	storm.material_override["shader_parameter/u_stormStr"] = game_progress
	
	if int(global_time) % 5 < .25:
		uniform_changed.emit("u_invert",abs(sin(global_time*10.))*.15)
	else:
		uniform_changed.emit("u_invert",-abs(sin(global_time))*.25)
	
	uniform_changed.emit("u_filmgrain",0.5+game_progress*.5)
	uniform_changed.emit("u_vignette",-game_progress)
	
	#uniform_changed.emit("u_abbrLevel",sin(global_time))
	if damage_time > 0:
		var rx = randf()
		var ry = randf()
		uniform_changed.emit("u_abbrEnv",.5+2*damage_time)
		uniform_changed.emit("u_shakeX",rx*damage_time*.02)
		uniform_changed.emit("u_shakeY",ry*damage_time*.02)
	else:
		uniform_changed.emit("u_abbrEnv",.5)
		uniform_changed.emit("u_shakeX",0.)
		uniform_changed.emit("u_shakeY",0.)

# angle in rads
func rotate_cam_to_pos(angle: float):
	camera_origin.rotation = Vector3(0,deg_to_rad(fmod(angle, 360.0)),0)

func set_game_progress_ratio(progress: float):
	game_progress = progress
	camera_follow.progress_ratio = progress;

func feedback(name: String):
	if name == "spawn_object":
		pent_bright = 2

func move_camera_forward(delta:float):
	return

func on_player_health_changed(old_value,new_value):
	health = new_value
	if new_value < old_value:
		damage_time = 1.
