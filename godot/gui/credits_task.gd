class_name CreditsTask

extends Control

@export var task_text: String
@export var persons: PackedStringArray

@onready var task_label := %TaskLabel
@onready var persons_flow_container := %PersonsFlowContainer

func _ready():
	task_label.text = tr(task_text)
	for person: String in persons:
		var person_label := Label.new()
		person_label.text = person
		persons_flow_container.add_child(person_label)
