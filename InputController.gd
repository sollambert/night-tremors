extends CanvasLayer

enum ControlScheme {
	FIRST_PERSON, PAUSE_MENU, INVENTORY, UNFOCUSED, INTRO, GAME_WON
}

# state
var mouse_delta: Vector2 = Vector2()
var previous_scheme


# player controls
signal player_shoot
signal player_shoot_held
signal player_jump
signal player_reload
signal player_move(movement_vector, delta)
signal player_sprint(delta: float, started: bool)
signal player_flashlight(pressed: bool)
signal player_mouse_motion(mouse_delta: float)
signal player_weapon_switch(weapon_id: int)

signal game_focused

var active_scheme

# Components
var scene_controller: Node3D
var ui_controller: CanvasLayer

const BASE_RESOLUTION : Vector2i = Vector2i(1280, 720)

# Called when the node enters the scene tree for the first time.
func _ready():
	scene_controller = get_node("/root/Main/SceneController")
	ui_controller = get_node("/root/Main/ViewContainer/UIController")
	scene_controller.game_won.connect(_on_scene_controller_game_won)
	scene_controller.set_game_paused(true)
	process_mode = Node.PROCESS_MODE_ALWAYS
	connect_signals()
	pass # Replace with function body.

func connect_signals():
	ui_controller.intro_button_pressed.connect(_on_intro_button_pressed)
	get_node("/root/Main/ViewContainer/UIController/Intro_1").opened.connect(_on_intro_opened)
	get_node("/root/Main/ViewContainer/UIController/VideoSettings").opened.connect(_on_video_settings_opened)
	
func _on_video_settings_opened():
	change_control_scheme(ControlScheme.PAUSE_MENU)
func _on_intro_opened():
	change_control_scheme(ControlScheme.INTRO)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match active_scheme:
		ControlScheme.PAUSE_MENU:
			pass
		ControlScheme.FIRST_PERSON:
			player_mouse_motion.emit(mouse_delta, delta)
			mouse_delta = Vector2()
			pass
		ControlScheme.UNFOCUSED:
			pass
	pass
	

func _input(event):
	if event.is_action_pressed("window_fullscreen_toggle"):
		toggle_fullscreen()
	else:
		match active_scheme:
			ControlScheme.INTRO:
				if event.is_action_pressed("menu_pause"):
					ui_controller.display_panel_by_name("HUD")
					change_control_scheme(ControlScheme.FIRST_PERSON)
					scene_controller.set_game_paused(false)
				pass
			ControlScheme.PAUSE_MENU:
				if event.is_action_pressed("menu_pause"):
					ui_controller.display_panel_by_name("HUD")
					change_control_scheme(ControlScheme.FIRST_PERSON)
					scene_controller.set_game_paused(false)
				pass
			ControlScheme.FIRST_PERSON:
				if event is InputEventMouseMotion:
					mouse_delta = event.relative
				elif event.is_action_pressed("player_flashlight"):
					player_flashlight.emit(true)
				elif event.is_action_released("player_flashlight"):
					player_flashlight.emit(false)
				elif event.is_action_pressed("player_reload"):
					player_reload.emit()
				elif event.is_action_pressed("menu_pause"):
					change_control_scheme(ControlScheme.PAUSE_MENU)
					ui_controller.display_panel_by_name("VideoSettings")
					scene_controller.set_game_paused(true)
				elif event.is_action_pressed("weapon_1"):
					player_weapon_switch.emit(1)
				elif event.is_action_pressed("weapon_2"):
					player_weapon_switch.emit(2)
				elif event.is_action_pressed("weapon_3"):
					player_weapon_switch.emit(3)
				pass
			ControlScheme.INVENTORY:
				pass
			ControlScheme.UNFOCUSED:
				pass
			ControlScheme.GAME_WON:
				if event.is_action_pressed("player_shoot"):
					get_tree().quit()
				pass
	pass

func _physics_process(delta):
	match active_scheme:
		ControlScheme.PAUSE_MENU:
			pass
		ControlScheme.FIRST_PERSON:
			var movement_vector = Input.get_vector("player_left", "player_right", "player_forward", "player_backward");
			player_move.emit(movement_vector, delta)
			if Input.is_action_pressed("player_sprint"):
				player_sprint.emit(delta, true)
			elif Input.is_action_just_released("player_sprint"):
				player_sprint.emit(delta, false)
			if Input.is_action_just_pressed("player_jump"):
				player_jump.emit()
			if Input.is_action_just_pressed("player_shoot"):
				player_shoot.emit()
			elif Input.is_action_pressed("player_shoot"):
				player_shoot_held.emit()
			pass
		ControlScheme.INVENTORY:
			pass
		ControlScheme.UNFOCUSED:
			if Input.is_action_just_pressed("player_shoot"):
				if (previous_scheme):
					change_control_scheme(previous_scheme)
			pass
	pass

func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_IN:
		scene_controller.set_game_paused(false)
		pass
	elif what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		if active_scheme == ControlScheme.GAME_WON:
			get_tree().quit()
		if active_scheme != ControlScheme.UNFOCUSED:
			change_control_scheme(ControlScheme.UNFOCUSED)
			scene_controller.set_game_paused(true)
			
func change_control_scheme(scheme):
	match scheme:
		ControlScheme.INTRO:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pass
		ControlScheme.PAUSE_MENU:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pass
		ControlScheme.INVENTORY:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pass
		ControlScheme.FIRST_PERSON:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			pass
		ControlScheme.UNFOCUSED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pass
		ControlScheme.GAME_WON:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			pass
	previous_scheme = active_scheme
	active_scheme = scheme

func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
func _on_scene_controller_game_won():
	change_control_scheme(ControlScheme.GAME_WON)
	scene_controller.set_game_paused(false)

func _on_intro_button_pressed():
	change_control_scheme(ControlScheme.FIRST_PERSON)
	scene_controller.set_game_paused(false)
	pass # Replace with function body.
