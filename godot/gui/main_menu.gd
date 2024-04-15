class_name MainMenu extends Control

signal start_game

@onready var start_button := %StartButton
@onready var credits_button := %CreditsButton
@onready var quit_button := %QuitButton

@onready var sfx_sound_slider := %SfxSoundSlider
@onready var sfx_sound_percent_label := %SfxSoundPercentLabel

@onready var music_sound_slider := %MusicSoundSlider
@onready var music_sound_percent_label := %MusicSoundPercentLabel

@onready var sfx_bus_name := 'SFX'
@onready var music_bus_name := 'Music'

const credits_scene := preload("res://gui/credits.tscn")

func _ready():
	start_button.pressed.connect(self._on_start_button_pressed);
	credits_button.pressed.connect(self._on_credits_button_pressed)
	quit_button.pressed.connect(self._on_quit_button_pressed);
	sfx_sound_slider.value_changed.connect(self._on_sfx_sound_slider_value_changed)
	music_sound_slider.value_changed.connect(self._on_music_sound_slider_value_changed)

	if OS.has_feature('web'):
		quit_button.visible = false

	sfx_sound_slider.value = 80
	music_sound_slider.value = 80

func _on_credits_button_pressed() -> void:
	var credits := credits_scene.instantiate()
	add_child(credits)

func _on_start_button_pressed() -> void:
	start_game.emit()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_sfx_sound_slider_value_changed(volume_value: float) -> void:
	set_bus_volume(sfx_bus_name, volume_value, sfx_sound_percent_label)

func _on_music_sound_slider_value_changed(volume_value: float) -> void:
	set_bus_volume(music_bus_name, volume_value, music_sound_percent_label)

func set_bus_volume(bus_name: String, volume_percent: float, label_node: Label ):
	var bus_index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db (bus_index, linear_to_db(volume_percent / 100))
	label_node.text = "%d %%" % volume_percent

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
