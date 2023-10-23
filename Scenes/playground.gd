extends Node3D

var animation_player : AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player = get_node("AnimationPlayer")
	animation_player.play("Take 001")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(!animation_player.is_playing()):
		animation_player.play("Take 001")
	animation_player.advance(delta / 6)
	pass
