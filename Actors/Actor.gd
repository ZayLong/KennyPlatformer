extends Node2D

# PROPERTIES ============================================================================
onready var animated_sprite = $AnimatedSprite
onready var hitbox = $Hitbox
var velocity:Vector2 = Vector2.ZERO
var max_run:int = 300
var run_accel:int = 600
var gravity: int = 1000
var max_fall:int = 160
var jump_force:int = -160
var jump_hold_time:float = 0.25
var local_hold_time:float = 0.0
var is_grounded:bool = false

var remainder = Vector2.ZERO

# CORE ============================================================================
func _ready()->void:
	add_to_group("Actors")
	print("PLAYER BOTTOm IS: ", hitbox.bottom)
	print("PLAYER TOP IS: ", hitbox.top)
	pass

func _process(delta)->void:
	# subtracting right left input will return a float
	# wrapping sign around it will force it to return either -1 or 1
	var direction = sign(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	var jumping = Input.is_action_just_pressed("ui_up")
	is_grounded = CollisionManager.check_walls_collision(self, Vector2.DOWN)
	# if we are jumping and on the ground, then we can apply our jump force directly to our y velocity.
	# jump force should be a negative value because below we are += adding to our velocity
	# our local_hold_time should then bet set to jump_hold_time 
	# if we're not jumping and on the grou,d but our  local_hold_time is greater than zero, and if we are jumping, we can apply our jump force
	# if we're not jumping but our lcoal_hold_time is greater than zero then we will just zero it out
	# local_hold_time basically determines how long we can ascend, by letting go of the jump button, between the initial ump and local_hold_time's highest value
	# we will decrease our jump height
	if jumping && is_grounded:
		velocity.y = jump_force
		local_hold_time = jump_hold_time
	elif local_hold_time > 0:
		if Input.is_action_pressed("ui_up"):
			velocity.y = jump_force
		else: 
			local_hold_time = 0
	
	# our local_hold time is being continulously subtracted based on delta, sort of like a timer.
	local_hold_time -= delta

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	# move towards will move us towards a given vector, overtime
	# we are moving from our current x velocity, to the value of max_run * direction. direction will be either -1 or 1 so we're moving left or right
	# and multiplying that -1 or 1 by max_run will determine the top speed that we're moving in a given direction
	# run_accel * delta is the time it takes to move over time, 
	velocity.x = move_toward(velocity.x, max_run * direction, run_accel * delta)
	velocity.y = move_toward(velocity.y, max_fall, gravity * delta)

	#move_x(velocity.x * delta, funcref(self, "on_collision_x"))
	# we have to set our global position because this script assumses the hierarchy is an empty node2D
	# global_position.x  += velocity.x * delta
	# instead of using this though, we have this move method, that will take out velocity and delta, 
	# change it to a whole number then apply that to our global_position instead
	# the reason why is because i guess whole numbers is an easier way of dealing with physics related stuff
	# the creator of celeste seems to prefer working with whole numbers for this reason
	# and that platformer is largly praised for its feel, so i wont argue
	move_x(velocity.x * delta, funcref(self, "on_collision_x"))
	move_y(velocity.y * delta, funcref(self, "on_collision_y"))
	
	pass

# METHODS ============================================================================
func on_collision_x()->void:
	velocity.x = 0
	zero_remainder_x()

func on_collision_y()->void:
	velocity.y = 0
	zero_remainder_y()

# round to nearest int to keep our movement within whole numbers
func move_x(amount, callback)->void:
	remainder.x += amount
	var move = round(remainder.x)
	if move != 0:
		remainder.x -=move
		move_x_exact(move, callback)
	pass

func move_x_exact(amount, callback)->void:
	# the direction we will move pixel by pixel
	var step = sign(amount)
	while(amount != 0):
		# if we did hit a wall in either left or right direction (depending if step is 1/-1)
		if CollisionManager.check_walls_collision(self, Vector2(step, 0)):
			# we hit something, execute our callback, normally will be a stop velocity on axis
			callback.call_func()
			return
		global_position.x += step
		amount -= step

func move_y(amount, callback)->void:
	remainder.y += amount
	var move = round(remainder.y)
	if move != 0:
		remainder.y -=move
		move_y_exact(move, callback)
	pass

func move_y_exact(amount, callback = null)->void:
	# the direction we will move pixel by pixel
	# sign(float). if the float we return is negative, it will return -1
	# if the float is positive it will return 1, if it is zero it will return 0
	# this is useful because it can give us a direction to work with

	var step = sign(amount)
	while(amount != 0):
		
		if CollisionManager.check_walls_collision(self, Vector2(0, step)):
			callback.call_func()
			return
		global_position.y += step
		amount -= step

func zero_remainder_x()->void:
	remainder.x = 0
func zero_remainder_y()->void:
	remainder.y = 0

func is_riding(solid, offset)->bool:
	return !hitbox.intersects(solid.hitbox, Vector2.ZERO) && hitbox.intersects(solid.hitbox, offset)

func squish()->void:
	print("SQUISHED")
