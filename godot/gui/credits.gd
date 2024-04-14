extends Control

const credits_persons := preload("res://gui/credits_persons.json")
const credits_task := preload("res://gui/credits_task.tscn")

func _ready():
	if credits_persons.data is Dictionary:
		var persons = credits_persons.data as Dictionary
		for task_key in persons:
			var persons_name := PackedStringArray(persons[task_key])
			var credits_task_instance := credits_task.instantiate()
			credits_task_instance.task_text = task_key
			credits_task_instance.persons = persons_name
			add_child(credits_task_instance)
