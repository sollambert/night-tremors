extends Weapon

@export var projectile_count: int = 8

func _on_input_controller_player_shoot():
	if weapon_type == WeaponTypes.SEMI:
		if ammo_magazine > 0 and !is_reloading and fire_rate_timer.is_stopped():
			play_sound(sound_gunshot)
			var rng = RandomNumberGenerator.new()
			for n in projectile_count:
				var x_deviation = rng.randf_range(weapon_spread * -1, weapon_spread)
				var y_deviation = rng.randf_range(weapon_spread * -1, weapon_spread)
				var z_deviation = rng.randf_range(weapon_spread * -1, weapon_spread)
				var bullet : Node3D = bullet_scene.instantiate()
				bullet.damage = damage
				bullet.speed = projectile_speed
				get_node("/root/Main").add_child(bullet)
				bullet.global_transform = muzzle.global_transform
				bullet.rotate_x(x_deviation)
				bullet.rotate_y(y_deviation)
				bullet.rotate_z(z_deviation)
			update_ammo_magazine(ammo_magazine - 1)
			muzzle.flash()
			fire_rate_timer.start(fire_rate)
