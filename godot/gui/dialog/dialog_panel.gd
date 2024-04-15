extends Panel

var tween : Tween

func _ready():
	tween = create_tween()

var text : String:
	set(value):
		$Label.text = value
		$Label.visible_ratio = 0.0
		tween.stop()
		tween = create_tween()
		tween.tween_property($Label, "visible_ratio", 1.0, value.length() * 0.05).from_current()
		tween.play()
	get:
		return $Label.text
