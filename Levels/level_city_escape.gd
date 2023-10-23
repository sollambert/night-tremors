extends Node3D

var scene_controller

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = get_node("/root/Main/ViewContainer/SubViewport/Player")
	var input_controller = get_node("/root/Main/InputController")
	var ui_controller = get_node("/root/Main/ViewContainer/UIController")
	var player_start = get_node("Player_Start")
	scene_controller = get_node("/root/Main/SceneController")
	ui_controller.display_panel_by_name("Intro_1")
	pass # Replace with function body.


func _on_exit_car_entered():
	scene_controller.load_level(1)
	pass # Replace with function body.
