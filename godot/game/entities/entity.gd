class_name Entity
extends Area2D

signal collision(obstacle)

var damage = 50

# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func on_body_entered(body):
	body.take_damage(damage)
	#collision.emit(self)


#func on_player_entity_collision(hit_player, entity):
	#hit_player.take_damage(50)
	#pass

func connect_signals(level):
	#collision.connect(level.on_player_entity_collision)
	pass
