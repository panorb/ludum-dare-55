extends Entity

signal page_spawn(book)

@onready var animation_player = $Graphics/AnimationPlayer

const GRAVITY = 9

var speed = Vector2.ZERO
var rot_speed = 0.0
var page_spawn_timer = null
var has_spawned = false

func init(start_x, start_y, speed_x, speed_y):
	damage = 45
	position.x = start_x
	position.y = start_y
	speed = Vector2(speed_x, speed_y)
	rotation = randf()*PI
	rot_speed = randf()*2*PI*0.01-PI*0.01


# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	animation_player.play("idle")
	page_spawn_timer = Timer.new()
	page_spawn_timer.one_shot = true
	page_spawn_timer.timeout.connect(on_page_spawn)
	add_child(page_spawn_timer)

func _move(delta):
	position += speed*delta
	#speed.y += GRAVITY
	speed.y = min(speed.y+GRAVITY, 200)
	rotation += rot_speed
	if position.y > 400:
		queue_free()
	if randi()%50 == 0 and not has_spawned:
		#page_spawn.emit(self)
		has_spawned = true
		page_spawn_timer.start(0.6)
		animation_player.play("page_spawn")

func on_page_spawn():
	page_spawn.emit(self)

func connect_signals(level):
	page_spawn.connect(level.page_spawn)

func on_player_collision(player):
	player.take_damage(damage)
	player.inertia += (player.position-position).normalized()*1000

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
