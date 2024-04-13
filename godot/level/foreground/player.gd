extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# wasd movement
	var direction = Vector2()
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1

	
	if direction.length() > 0:
		direction = direction.normalized()
		position += direction * 200 * delta
		# when to the left, the sprite is flipped
		if direction.x < 0:
			$Node2D/Sprite2D.flip_v = true
		else:
			$Node2D/Sprite2D.flip_v = false

		rotation = direction.angle()
		
