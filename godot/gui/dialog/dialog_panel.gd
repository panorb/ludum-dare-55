extends Panel

func _ready():
	visible = false

var text : String:
	set(value):
		$Label.text = value
		visible = (len(value) > 0)
		if not visible:
			return
		$Label.visible_ratio = 0.0
		var tween = create_tween()
		tween.tween_property($Label, "visible_ratio", 1.0, value.length() * 0.05).from_current()
		tween.play()
	get:
		return $Label.text
