extends Node2D

@onready var move_area : Area2D = get_node("MoveArea")

func _ready() -> void:
	move_area.body_entered.connect(_on_move_area_body_entered)
	move_area.body_exited.connect(_on_move_area_body_exited)

func _on_move_area_body_entered(body: Node2D) -> void:
	pass

func _on_move_area_body_exited(body: Node2D) -> void:
	pass
