extends CanvasLayer

var intro : Control
var video_settings: Control
var hud_overlay : CanvasLayer
var input_controller : CanvasLayer
var scene_controller : Node3D
var game_complete: ColorRect

signal intro_button_pressed

var panels = []

# Called when the node enters the scene tree for the first time.
func _ready():
	input_controller = get_node("/root/Main/InputController")
	scene_controller = get_node("/root/Main/SceneController")
	scene_controller.game_won.connect(_on_game_won)
	for child in get_children():
		child.set_process(false)
		child.visible = false
		panels.append(child)
#	connect_signals()
	pass # Replace with function body.
	
func _on_game_won():
	display_panel_by_name("GameWon")

#func connect_signals():
#	get_node("Intro_1/ColorRect/IntroButton").pressed.connect(_on_intro_button_pressed)

func _on_intro_button_pressed():
	print("intro button pressed")
	display_panel_by_name("HUD")
	intro_button_pressed.emit()

func display_panel_by_name(name: String):
	for panel in panels:
		if panel.get_name() == name:
			process_mode = Node.PROCESS_MODE_ALWAYS
			panel.set_process(true)
			panel.visible = true
			if "opened" in panel:
				panel.opened.emit()
		else:
			process_mode = Node.PROCESS_MODE_PAUSABLE
			panel.set_process(false)
			panel.visible = false