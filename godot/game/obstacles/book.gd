extends Area2D

signal collision(obstacle)

const GRAVITY = 9

var initiated
var speed

@onready var collision_polygon_2d = $CollisionPolygon2D


func init(start_x, start_y, speed_x, speed_y):
	position.x = start_x
	position.y = start_y
	speed = Vector2(speed_x, speed_y)
	initiated = true


# Called when the node enters the scene tree for the first time.
func _ready():
	body_entered.connect(on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not initiated:
		return
	position.x += speed.x*delta
	position.y += speed.y*delta
	speed.y += GRAVITY
	if position.y > 2000:
		queue_free()


func on_body_entered(body):
	collision.emit(body, self)
