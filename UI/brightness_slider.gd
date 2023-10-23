extends HSlider

var world_environment : WorldEnvironment

func _ready():
	value_changed.connect(_on_value_changed)
	world_environment = get_node("/root/Main/WorldEnvironment")
	pass # Replace with function body.

func _on_value_changed(amount):
	world_environment.get_environment().adjustment_brightness = amount
	pass # Replace with function body.
