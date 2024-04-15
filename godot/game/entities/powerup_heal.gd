extends Entity

@onready var animation_player = $Graphics/AnimationPlayer

const GRAVITY = 9

var speed

func init(start_x, start_y, speed_x, speed_y):
	damage = 200
	position.x = start_x
	position.y = start_y
	speed = Vector2(speed_x, abs(speed_y))


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	animation_player.play("idle")

func _move(delta):
	position += speed*delta
	if position.y > 400:
		queue_free()

func on_player_collision(player):
	player.heal(damage)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
