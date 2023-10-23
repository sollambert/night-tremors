extends Node3D

var flash_light: OmniLight3D
var flash_timer: Timer

const FLASH_DELAY = 0.075

func _ready():
	flash_light = get_node("Flash")
	flash_timer = get_node("FlashTimer")	

func flash():
	flash_light.visible = true
	flash_timer.start(FLASH_DELAY)


func _on_flash_timer_timeout():
	flash_light.visible = false
	pass # Replace with function body.
