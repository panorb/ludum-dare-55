extends Control

const credits_persons := preload("res://gui/credits_persons.json")

@onready var main_v_box_container := %MainVBoxContainer

func _ready():
	if credits_persons.data is Dictionary:
		var persons = credits_persons.data as Dictionary
		for task_key in persons:
			var person_names := PackedStringArray(persons[task_key])
			
			var task_rich_text_label = RichTextLabel.new()
			task_rich_text_label.text = "[center][b]%s[/b][/center]" % tr(task_key)
			task_rich_text_label.bbcode_enabled = true
			task_rich_text_label.fit_content = true
			main_v_box_container.add_child(task_rich_text_label)
			
			var person_names_rich_text_label := RichTextLabel.new()
			person_names_rich_text_label.text = "[center]%s[/center]\n " % " | ".join(person_names)
			person_names_rich_text_label.bbcode_enabled = true
			person_names_rich_text_label.fit_content = true
			main_v_box_container.add_child(person_names_rich_text_label)
