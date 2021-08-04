extends "res://Actors/Enemies/BlueBug/Blue Bug.gd"


# override
func execute_physics(_delta)->void:
	_flying_movement(_delta)
	_flip_sprite()
	pass

func _flying_movement(_delta):
	# acceleration/deceleration clamp
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	# sine wave based movement
	time += _delta
	# distance between the waves
	# basically our speed, how many peaks do we get in a cycle?
	var frequency = 0.25
	# high high the waves are
	var amplitude = 100
	 # position.x = (time*15)*5
	# position.x = sin(time*amplitude)*frequency
	motion.x += ACCEL
	motion.y = amplitude * (sin(frequency * (position.x)))
	var collision = move_and_collide(motion * _delta)

	pass



func _on_DamagePlayerArea2D_body_entered(body: PlayerController):
	if body != null:
		if body.name == "Player":
			body.take_damage(1, position)
	pass # Replace with function body.
