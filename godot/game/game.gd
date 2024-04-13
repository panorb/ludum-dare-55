extends Node2D

@onready var sub_viewport : SubViewport = get_node("%SubViewport")

func _ready():
	_on_window_size_changed()
	get_tree().get_root().size_changed.connect(_on_window_size_changed)

func _on_window_size_changed():
	sub_viewport.size = get_tree().get_root().size
