class_name MainMenu extends Control

signal start_game
signal show_credits

@onready var start_button := %StartButton
@onready var credits_button := %CreditsButton
@onready var quit_button := %QuitButton
@onready var sound_slider := %SoundSlider
@onready var sound_percent_label := %SoundPercentLabel

@onready var master_bus_name := 'Master'

func _ready():	
	start_button.pressed.connect(self._on_start_button_pressed);
	credits_button.pressed.connect(self._on_credits_button_pressed)
	quit_button.pressed.connect(self._on_quit_button_pressed);
	sound_slider.value_changed.connect(self._on_sound_slider_value_changed);
	
	if OS.has_feature('web'):
		quit_button.visible = false
		
	sound_slider.value = 80;

func _on_credits_button_pressed() -> void:
	show_credits.emit()

func _on_start_button_pressed() -> void:
	start_game.emit()
	
func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_sound_slider_value_changed(volume_value: float) -> void:
	var master_bus_index := AudioServer.get_bus_index('Master')
	AudioServer.set_bus_volume_db (master_bus_index, linear_to_db(volume_value / 100))
	sound_percent_label.text = "  %d %%" % volume_value

	#if volume_value <= 0 :
	#	sound_image.texture = volume_mute_image
	#elif volume_value > 0 && volume_value <=25:
	#	sound_image.texture = volume_25_image
	#elif volume_value > 25 && volume_value <=50:
	#	sound_image.texture = volume_50_image
	#elif volume_value > 50 && volume_value <=75:
	#	sound_image.texture = volume_75_image
	#elif volume_value > 75 && volume_value <=100:
	#	sound_image.texture = volume_full_image
