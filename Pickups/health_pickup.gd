extends Pickup

func _on_pickup(player):
	player.add_health(value)
