extends AudioStreamPlayer

var stopped = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !playing and !stopped:
		play()
	pass

func stop_music():
	stopped = true
	stop()
