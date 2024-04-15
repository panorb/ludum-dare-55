extends Node

const start_scene := 'main_menu'

const main_menu_scene := preload("res://gui/main_menu.tscn")

var scenes := {
	'main_menu': main_menu_scene,
	'game': preload("res://game/game.tscn"),
	'lose_screen': preload("res://gui/end_screen/lose_screen.tscn"),
	'win_screen':  preload("res://gui/end_screen/win_screen.tscn"),
}

@onready var current_scene_node: Node = null
@onready var current_scene_key: String
@onready var current_scene: String:
	get:
		return current_scene_key
	set(value):
		if self.current_scene_node != null:
			self.remove_child(self.current_scene_node)
		var next_scene: PackedScene = scenes[value]
		var next_scene_node: Node = next_scene.instantiate()
		self.add_child(next_scene_node)
		self.current_scene_key = value
		self.current_scene_node = next_scene_node

		if next_scene_node is MainMenu:
			var main_menu_node = next_scene_node as MainMenu
			main_menu_node.start_game.connect(_on_game_start)
		elif next_scene_node is LoseScreen:
			var lose_node = next_scene_node as LoseScreen
			lose_node.show_main_menu.connect(_on_show_main_menu)
		elif next_scene_node is WinScreen:
			var win_node = next_scene_node as WinScreen
			win_node.show_main_menu.connect(_on_show_main_menu)

func _ready():
	self.current_scene = start_scene
	TranslationServer.set_locale("en")

func _on_game_start():
	self.current_scene = 'game'

func _on_show_main_menu():
	self.current_scene = 'main_menu'
