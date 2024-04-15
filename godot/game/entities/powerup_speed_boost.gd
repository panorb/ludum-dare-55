extends Entity

const GRAVITY = 9

var speed

func init(start_x, start_y, speed_x, speed_y):
	damage = 10
	position.x = start_x
	position.y = start_y
	speed = Vector2(speed_x, abs(speed_y))


# Called when the node enters the scene tree for the first time.
func _ready():
	super()

func _move(delta):
	position += speed*delta
	if position.y > 2000:
		queue_free()

func on_player_collision(player):
	player.boost_speed(damage)
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
