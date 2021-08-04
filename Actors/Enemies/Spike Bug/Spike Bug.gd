extends "res://Actors/Enemies/BlueBug/Blue Bug.gd"


func got_attacked(area:Area2D)->void:
	if area.name == "FeetArea2D":
		var player:PlayerController = area.owner
		player.take_damage(1, position)
	pass
