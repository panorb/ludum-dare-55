extends Entity

signal page_spawn(book)

@onready var animation_player = $Graphics/AnimationPlayer

const GRAVITY = -4

var speed = Vector2.ZERO
var rot_speed = 0.0
var has_spawned = false

func init(start_x, start_y, speed_x, speed_y):
	damage = 100
	position.x = start_x
	position.y = start_y
	speed = Vector2(speed_x, speed_y)
	rotation = randf()*PI
	rot_speed = randf()*2*PI*0.01-PI*0.01


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	animation_player.play("idle")

func _move(delta):
	position += speed*delta
	speed.y += GRAVITY
	rotation += rot_speed
	if position.y < -200:
		queue_free()

func on_player_collision(player):
	player.take_damage(damage)
	player.inertia += (player.position-position).normalized()*500

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
