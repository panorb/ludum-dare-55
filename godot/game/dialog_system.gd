extends Control

@onready var wizard_panel = %WizardPanel
@onready var fly_panel = %FlyPanel

var cur_dialog_index = -1
var is_wizard_speaking = [true, true, true, true, false, false, false]

var passed_time = 0.0

signal dialog_finished


func _process(delta):
	if passed_time > 3.0:
		next_dialog_line()
		passed_time = 0.0
	passed_time += delta

func next_dialog_line():
	cur_dialog_index += 1
	
	if cur_dialog_index < is_wizard_speaking.size():
		if (is_wizard_speaking[cur_dialog_index]):
			wizard_panel.text = "DIALOG_" + str(cur_dialog_index)
		else:
			fly_panel.text = "DIALOG_" + str(cur_dialog_index)
	else:
		dialog_finished.emit()
