extends Node2D

@onready var sub_viewport : SubViewport = get_node("%SubViewport")
@onready var move_area : Area2D = get_node("MoveArea")

func _ready():
	_on_window_size_changed()
	get_tree().get_root().size_changed.connect(_on_window_size_changed)
	move_area.body_entered.connect(_on_move_area_body_entered)
	move_area.body_exited.connect(_on_move_area_body_exited)

func _on_window_size_changed():
	sub_viewport.size = get_tree().get_root().size

func _on_move_area_body_entered(body: Node2D) -> void:
	pass

func _on_move_area_body_exited(body: Node2D) -> void:
	pass
