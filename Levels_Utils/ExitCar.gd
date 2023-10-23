extends Area3D

signal entered
var scene_controller: Node3D

func _on_body_entered(body):
	if body.get_name() == "Player":
		entered.emit()
	pass # Replace with function body.
