extends Node

const start_scene := 'main_menu'

const main_menu_scene := preload("res://gui/main_menu.tscn")

var scenes := {
	'main_menu': main_menu_scene,
	'game': preload("res://game/game.tscn"),
}

@onready var current_scene_node: Node = null
@onready var current_scene_key: String 
@onready var current_scene: String:
	get:
		return current_scene_key
	set(value):
		self.remove_child(self.current_scene_node)
		var next_scene: PackedScene = scenes[value]
		var next_scene_node: Node = next_scene.instantiate()
		self.add_child(next_scene_node)
		self.current_scene_key = value
		self.current_scene_node = next_scene_node
		
		if next_scene_node is MainMenu:
			var main_menu_node = next_scene_node as MainMenu
			main_menu_node.start_game.connect(_on_game_start)
			

func _ready():
	self.current_scene = start_scene

func _on_game_start():
	print('start game')
	self.current_scene = start_scene
	
func _on_game_start():
	current_scene = 'game'

