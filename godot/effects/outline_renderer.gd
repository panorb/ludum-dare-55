extends Node2D

@onready var outline_subviewport = %OutlineSubviewport
@onready var outline_texture = %OutlineTexture

@onready var element_to_render = %ElementToRender

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# rotate
	element_to_render.rotation_degrees += Vector3(1, 1, 1) * 100 * delta
	pass
