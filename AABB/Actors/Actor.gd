extends Node2D
class_name Actor
# PROPERTIES ============================================================================

onready var hitbox:HitBox = $Hitbox
var velocity:Vector2 = Vector2.ZERO
var remainder:Vector2 = Vector2.ZERO

# CORE ============================================================================
func _ready()->void:
	add_to_group("Actors")
	pass


# METHODS ============================================================================
func on_collision_x()->void:
	velocity.x = 0
	zero_remainder_x()

func on_collision_y()->void:
	velocity.y = 0
	zero_remainder_y()

# round to nearest int to keep our movement within whole numbers
func move_x(amount:float, callback)->void:
	remainder.x += amount
	var move = round(remainder.x)
	if move != 0:
		remainder.x -=move
		move_x_exact(move, callback)
	pass

func move_x_exact(amount:float, callback)->void:
	# the direction we will move pixel by pixel
	var step = sign(amount)
	while(amount != 0):
		# if we did hit a wall in either left or right direction (depending if step is 1/-1)
		if CollisionManager.check_walls_collision(self, Vector2(step, 0)) || CollisionManager.check_tiles_collision(self, Vector2(step, 0)) || CollisionManager.check_actor_group_collision(self, "Blocks", Vector2(step,0)).size() > 0:
			# we hit something, execute our callback, normally will be a stop velocity on axis
			callback.call_func()
			return
		global_position.x += step
		amount -= step
	pass

func move_y(amount:float, callback)->void:
	remainder.y += amount
	var move = round(remainder.y)
	if move != 0:
		remainder.y -=move
		move_y_exact(move, callback)
	pass

func move_y_exact(amount:float, callback = null)->void:
	# the direction we will move pixel by pixel
	# sign(float). if the float we return is negative, it will return -1
	# if the float is positive it will return 1, if it is zero it will return 0
	# this is useful because it can give us a direction to work with

	var step = sign(amount)
	while(amount != 0):
		
		if CollisionManager.check_walls_collision(self, Vector2(0, step)) || CollisionManager.check_tiles_collision(self, Vector2(0, step)) || CollisionManager.check_actor_group_collision(self, "Blocks", Vector2(0,step)).size() > 0:
			callback.call_func()
			return
		global_position.y += step
		amount -= step
	pass

func zero_remainder_x()->void:
	remainder.x = 0
	pass

func zero_remainder_y()->void:
	remainder.y = 0
	pass

func is_riding(solid:Solid, offset:Vector2)->bool:
	return !hitbox.intersects(solid.hitbox, Vector2.ZERO) && hitbox.intersects(solid.hitbox, offset)

func is_riding_tile(tile_pos:Vector2, cell_size:Vector2, offset:Vector2)->bool:
	return !hitbox.intersects_tile(tile_pos, cell_size, Vector2.ZERO) && hitbox.intersects_tile(tile_pos, cell_size, offset)

func is_hugging_tile(tile_pos:Vector2, cell_size:Vector2, offset:Vector2)->bool:
	return !hitbox.intersects_tile(tile_pos, cell_size, Vector2.ZERO) && hitbox.intersects_tile(tile_pos, cell_size, offset)
	pass

func squish()->void:
	print("SQUISHED")
