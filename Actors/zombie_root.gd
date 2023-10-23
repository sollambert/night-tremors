extends Node3D

@export var revives : int = -1
@export var follow_distance : float = 6.0

func _ready():
	var zombie = get_node("RootNode")
	zombie.revives = revives
	zombie.follow_distance = follow_distance
	
	
func set_revives(amount):
	revives = amount

func set_follow_distance(amount):
	follow_distance = amount
