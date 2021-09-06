extends Enemy
class_name FlyingEnemy

# PROPERTIES ============================================================================
const max_run:int = 50
var current_run:int = max_run

const max_run_accel:int = 150
var current_run_accel:int = max_run_accel

var direction:int = 1
# CORE ============================================================================

func _process(delta)->void:
		# distance between the waves
	# basically our speed, how many peaks do we get in a cycle?
	var frequency = 0.25
	# high high the waves are
	var amplitude = 100
	
	detect_hit_collision()
	velocity.x = move_toward(velocity.x, current_run * direction, current_run_accel * delta)
	velocity.y = amplitude * (sin(frequency * (global_position.x)))
	
	#velocity.y = move_toward(velocity.y, amplitude * (sin(frequency * (velocity.x))), delta)
	
	move_x(velocity.x * delta, funcref(self, "on_collision_x"))
	move_y(velocity.y * delta, funcref(self, "on_collision_y"))

# METHODS ============================================================================

#OVERRIDE
func move_x_exact(amount:float, callback)->void:
	# the direction we will move pixel by pixel
	var step = sign(amount)
	while(amount != 0):
		# if we did hit a wall in either left or right direction (depending if step is 1/-1)
		if CollisionManager.check_actor_group_collision(self, "Player", Vector2(step,0)):
			# we hit something, execute our callback, normally will be a stop velocity on axis
			callback.call_func()
			return
		global_position.x += step
		amount -= step
	pass

#OVERRIDE
func move_y_exact(amount:float, callback = null)->void:
	# the direction we will move pixel by pixel
	# sign(float). if the float we return is negative, it will return -1
	# if the float is positive it will return 1, if it is zero it will return 0
	# this is useful because it can give us a direction to work with

	var step = sign(amount)
	while(amount != 0):
		
		if  CollisionManager.check_actor_group_collision(self, "Player", Vector2(0,step)):
			callback.call_func()
			return
		global_position.y += step
		amount -= step
	pass
