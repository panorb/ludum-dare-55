extends Node2D

var warn_indicator_scene := preload("res://warning_indicator/warn_indicator.tscn")
const INITIAL_WARN_INDICATOR_POOL_SIZE = 20

func _ready():
	for i in range(INITIAL_WARN_INDICATOR_POOL_SIZE):
		_add_new_warn_indicator_instance()

func _add_new_warn_indicator_instance():
	var warn_indicator_instance = warn_indicator_scene.instantiate()
	warn_indicator_instance.visible = false
	add_child(warn_indicator_instance)

func update(viewport_size: Vector2, screen_center_level_position: Vector2):
	_update_edge_warns(viewport_size, screen_center_level_position)

func _update_edge_warns(viewport_size: Vector2, screen_center_level_position: Vector2):
	var warn_entities : Array[Node] = get_tree().get_nodes_in_group("edge-warn")
	var warn_entity_count = warn_entities.size() 
	var viewport_pos = screen_center_level_position - (viewport_size / 2)
	var viewport_rect = Rect2(viewport_pos, viewport_size).grow(-5)
	
	while (warn_entity_count > get_child_count()):
		_add_new_warn_indicator_instance()
	
	for i in range(get_child_count()):
		var warn_indicator = get_child(i)
		if i < warn_entities.size():
			if viewport_rect.has_point(warn_entities[i].position):
				warn_entities[i].entered_screen_once = true
				warn_indicator.disable()
			elif not warn_entities[i].entered_screen_once:
				var center_to_entity_vector : Vector2 = (warn_entities[i].position - screen_center_level_position)
				warn_indicator.position = _point_on_rect(center_to_entity_vector * 10000.0, get_viewport_rect().grow(-35))
				var nearest_edge_pos = _point_on_rect(center_to_entity_vector * 10000.0, viewport_rect)
				
				var distance = nearest_edge_pos.distance_to(warn_entities[i].position)
				warn_indicator.update_blinking_speed(distance)
		else:
			warn_indicator.disable()

func _point_on_rect(target: Vector2, rect: Rect2):
	var minX = rect.position.x
	var minY = rect.position.y
	var maxX = minX + rect.size.x
	var maxY = minY + rect.size.y
	
	var midX = (minX + maxX) / 2
	var midY = (minY + maxY) / 2
	
	var m = (midY - target.y) / (midX - target.x)
	
	if target.x <= midX: # check "left" side
		var minXy = m * (minX - target.x) + target.y
		if minY <= minXy and minXy <= maxY:
			return Vector2(minX, minXy)
	
	if target.x >= midX: # check "right" side
		var maxXy = m * (maxX - target.x) + target.y
		if minY <= maxXy && maxXy <= maxY:
			return Vector2(maxX, maxXy)
	
	if target.y <= midY:
		var minYx = (minY - target.y) / m + target.x
		if minX <= minYx and minYx <= maxX:
			return Vector2(minYx, minY)
	
	if target.y >= midY:
		var maxYx = (maxY - target.y) / m + target.x
		if minX <= maxYx and maxYx <= maxX:
			return Vector2(maxYx, maxY)
	
	if target.x == midX and target.x == midY:
		return target
