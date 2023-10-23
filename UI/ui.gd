extends Control


var sprint_bar : ProgressBar
var ammo_magazine : TextureProgressBar
var ammo_count: Label
var health: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	sprint_bar = get_node("sprint_bar")
	ammo_magazine = get_node("Ammo/magazine")
	ammo_count = get_node("Ammo/count")
	health = get_node("health")
	pass # Replace with function body.

func update_sprint_bar(value):
	sprint_bar.value = value
	pass
	
func set_ammo_ui_texture(texture):
	ammo_magazine.texture_progress = texture

func update_ammo_magazine(value, max_value):
	ammo_magazine.max_value = max_value
	ammo_magazine.value = value

func update_ammo_count(value):
	ammo_count.text = str(value)

func update_health(value):
	health.text= str(value) + "✚"
