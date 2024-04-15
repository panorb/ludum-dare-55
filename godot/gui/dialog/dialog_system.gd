extends Control

@onready var wizard_panel = %WizardPanel
@onready var fly_panel = %FlyPanel

var cur_dialog_index = -1
var is_wizard_speaking = [true, true, true, true, false, false, false]

const SYMBOLS_PER_SECOND = 7
var passed_time = 0.0
var hide_in = 4.0

#signal dialog_finished

func _ready():
	get_tree().paused = true
	next_dialog_line()

func _input(event):
	if event.is_action_pressed("ui_accept") and passed_time > 0.5:
		passed_time = 0.0
		next_dialog_line()

func _process(delta):
	if passed_time > hide_in && cur_dialog_index < is_wizard_speaking.size():
		passed_time = 0.0
		next_dialog_line()
	passed_time += delta

func next_dialog_line():
	if cur_dialog_index > is_wizard_speaking.size():
		%ExplainerPanel.visible = false
		return
	
	cur_dialog_index += 1
	
	if cur_dialog_index == is_wizard_speaking.size():
		%FlySpeakingSound.stop()
		%WizardSpeakingSound.stop()
		fly_panel.text = ""
		wizard_panel.text = ""
		%ExplainerPanel.visible = true
		return
	
	if cur_dialog_index < is_wizard_speaking.size():
		var phrase_len = 0
		if (is_wizard_speaking[cur_dialog_index]):
			wizard_panel.text = "DIALOG_" + str(cur_dialog_index)
			fly_panel.text = ""
			phrase_len = len(tr(wizard_panel.text))
			%FlySpeakingSound.stop()
			%WizardSpeakingSound.play()
		else:
			wizard_panel.text = ""
			fly_panel.text = "DIALOG_" + str(cur_dialog_index)
			phrase_len = len(tr(fly_panel.text))
			%WizardSpeakingSound.stop()
			%FlySpeakingSound.play()
		hide_in = phrase_len / SYMBOLS_PER_SECOND
	else:
		fly_panel.text = ""
		wizard_panel.text = ""
		#dialog_finished.emit()
		%ExplainerPanel.visible = false
		get_tree().paused = false
