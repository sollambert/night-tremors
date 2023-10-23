extends Area3D

@export var speed : float = 30.0
@export var damage : int = 10
var already_entered = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += global_transform.basis.z * speed * delta
	pass

func _destroy():
	queue_free()


func _on_body_entered(body):
	already_entered = true
	if body.has_method("take_damage"):
		body.take_damage(damage)
	_destroy()
	pass # Replace with function body.


func _on_body_exited(body):
	if !already_entered:
		if body.has_method("take_damage"):
			body.take_damage(damage)
		_destroy()
	pass # Replace with function body.
