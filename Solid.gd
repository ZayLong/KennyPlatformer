extends "res://Wall.gd"
class_name Solid
var remainder = Vector2.ZERO

func move_rider_x(amount)->void:
	remainder.x += amount
	var move = round(remainder.x)
	if move != 0:
		var riders = CollisionManager.get_all_riding_actors(self)
		remainder.x -= move
		global_position.x += move
		for actor in CollisionManager.get_all_actors():
			if hitbox.intersects(actor.hitbox, Vector2.ZERO):
				if move > 0:
					actor.move_x_exact(hitbox.right - actor.hitbox.left, funcref(actor, "squish"))
				else:
					actor.move_x_exact(hitbox.left - actor.hitbox.right, funcref(actor, "squish"))
			elif riders.has(actor):
				actor.move_x_exact(move, null)
	pass

func move_rider_y(amount)->void:
	remainder.y += amount
	var move = round(remainder.y)
	if move != 0:
		remainder.y -= move
		global_position.y += move
		hitbox.collidable = !jump_through
		var riders = CollisionManager.get_all_riding_actors(self)
		for actor in CollisionManager.get_all_actors():
			if hitbox.intersects(actor.hitbox, Vector2.ZERO):
				if move > 0:
					actor.move_y(hitbox.bottom - actor.hitbox.top, funcref(actor, "squish"))
				else:
					actor.move_y((hitbox.top - actor.hitbox.bottom), funcref(actor, "squish"))
			elif riders.has(actor):
				actor.move_y(move, null)
		hitbox.collidable = true
	pass
