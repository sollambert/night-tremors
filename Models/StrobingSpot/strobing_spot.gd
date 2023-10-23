extends Node3D

var rng: RandomNumberGenerator
var timer: Timer
var spot_on: bool = false
var spotlight: SpotLight3D
var spotlight_bulb: MeshInstance3D
const DELAY: float = 1.0

func _ready():
	rng = RandomNumberGenerator.new()
	timer = get_node("Timer")
	spotlight = get_node("SpotLight3D")
	spotlight_bulb = get_node("LightBulb")
	spotlight.visible = spot_on
	timer.start(rng.randf_range(0.1, DELAY))
	timer.timeout.connect(_on_timer_timeout)
	
func _on_timer_timeout():
	spot_on = !spot_on
	spotlight.visible = spot_on
	if spot_on:
		spotlight_bulb.get_active_material(0).shading_mode = 0
	else:
		spotlight_bulb.get_active_material(0).shading_mode = 1
	timer.stop()
	timer.start(rng.randf_range(0.1, DELAY))
