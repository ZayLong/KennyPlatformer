extends Actor
class_name PlatformerPlayer

# PROPERTIES ============================================================================
export(PackedScene) var LandingParticles2D
export(PackedScene) var RunningParticles2D

onready var animated_sprite:AnimatedSprite = $AnimatedSprite
onready var tween:Tween = $Tween
onready var animation_player:AnimationPlayer = $AnimationPlayer
onready var camera:Camera2D = $Camera2D

const max_run:int = 150
var current_run:int = max_run

const max_run_accel:int = 600
var current_run_accel:int = max_run_accel

const max_gravity:int = 1000
var gravity:int = max_gravity

const max_fall: int = 260
var current_fall:int = max_fall

var jump_force:int = -260
const jump_hold_time:float = 0.25
var local_hold_time:float = 0.0

const max_coyote_time:float = 0.2
var current_coyote_time:float = 0.0

const max_jump_buffer_time:float = 0.2
var current_jump_buffer_time:float = 0.0

var is_grounded:bool = false

var is_hugging_left_wall:bool = false
var is_hugging_right_wall:bool = false
const max_wall_hug_time:float = 1.5
var current_wall_hug_time:float = 0.0

const MAX_INVINCIBILITY_TIME:float = 1.5
var current_invincibility_time:float = 0.0

var coin_count:int = 0
var key_count:int = 0
var is_invincible:bool = false
var current_hp:float = 6.0
var max_hp:float = 6.0



signal took_damage(damage, current_hp, max_hp)
signal collected_coin(coin_value)
signal collected_key(key_value)
signal use_key(key_value)

# CORE ============================================================================
func _ready()->void:
	add_to_group("Player")

func _process(delta:float)->void:

	# subtracting right left input will return a float
	# wrapping sign around it will force it to return either -1 or 1
	var direction = 0

	direction = sign(Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"))
	var jumping = Input.is_action_just_pressed("ui_up")
	gravity = max_gravity
	# if we're attempting to jump, and there's no time on our jump buffer, give us some time
	if jumping && current_jump_buffer_time <= 0:
		current_jump_buffer_time = max_jump_buffer_time
	
	if CollisionManager.check_walls_collision(self, Vector2.DOWN) && is_grounded == false || CollisionManager.check_tiles_collision(self, Vector2.DOWN) && is_grounded == false || CollisionManager.check_actor_group_collision(self, "Blocks", Vector2.DOWN) && is_grounded == false:
		is_grounded = true
		land_tween()
		current_coyote_time = max_coyote_time
	# if we're not standing on a wall, and we're not standing on a tile, and we're not standing on a block, then we MUST be in the air, as in NOT on the ground
	elif !CollisionManager.check_walls_collision(self, Vector2.DOWN) && !CollisionManager.check_tiles_collision(self, Vector2.DOWN) && !CollisionManager.check_actor_group_collision(self, "Blocks", Vector2.DOWN):
		is_grounded = false
		
		
	# checking if we're hugging the wall for wall jump checking. the 5 scalar is to add 5 pixels of fault tolerance so the player can be 5 pixels away from the wall and still get a wall jump in
	# i'm tired of wall jumps being hard in old school games lol
	if CollisionManager.check_walls_collision(self, Vector2.LEFT * 5) || CollisionManager.check_tiles_collision(self, Vector2.LEFT * 5):
		if current_wall_hug_time < 0 && !is_hugging_left_wall:
			is_hugging_left_wall = true			
			current_wall_hug_time = max_wall_hug_time
	else:
		is_hugging_left_wall = false
	
	if CollisionManager.check_walls_collision(self, Vector2.RIGHT * 5) || CollisionManager.check_tiles_collision(self, Vector2.RIGHT * 5):
		if current_wall_hug_time < 0  && !is_hugging_right_wall:
			is_hugging_right_wall = true
			current_wall_hug_time = max_wall_hug_time
	else:
		is_hugging_right_wall = false
	
	# if we are jumping and on the ground, then we can apply our jump force directly to our y velocity.
	# jump force should be a negative value because below we are += adding to our velocity
	# our local_hold_time should then bet set to jump_hold_time 
	# if we're not jumping and on the ground but our  local_hold_time is greater than zero, 
	# and if we are jumping, we can apply our jump force
	# if we're not jumping but our lcoal_hold_time is greater than zero then we will just zero it out
	# local_hold_time basically determines how long we can ascend, by letting go of the jump button, between the initial ump and local_hold_time's highest value
	# we will decrease our jump height
	if jumping && is_grounded || jumping && current_coyote_time > 0 || current_jump_buffer_time > 0 && is_grounded:
		velocity.y = jump_force
		local_hold_time = jump_hold_time
		current_coyote_time = 0
		current_jump_buffer_time = 0
		jump_tween()
	elif local_hold_time > 0:
		if Input.is_action_pressed("ui_up"):
			velocity.y = jump_force
		else: 
			local_hold_time = 0
	elif local_hold_time <= 0 && !is_grounded && velocity.y < 0:
		# we've reached the peak of our jump and we're starting to come back down
		# we can take this time to reduce our gravity so we have a bit more mid air control
		#print(velocity.y)
		gravity = max_gravity / 2
		pass
	
	# we wall jumpin bois
	if is_hugging_right_wall && !is_grounded && current_wall_hug_time > 0:
		if Input.is_action_pressed("ui_left") && jumping:
			velocity.y = jump_force
			local_hold_time = jump_hold_time
			current_wall_hug_time = 0
		current_fall = max_fall / 4
		# we wall jumpin bois
	if is_hugging_left_wall && !is_grounded && current_wall_hug_time > 0:
		if Input.is_action_pressed("ui_right") && jumping:
			velocity.y = jump_force
			local_hold_time = jump_hold_time
			current_wall_hug_time = 0
		current_fall = max_fall / 4
	
	# we stopped hugging the wall, or we ran out of time, so our fall speed is reset
	if current_wall_hug_time <= 0 || !is_hugging_left_wall && !is_hugging_right_wall:
		current_fall = max_fall
	
	
	# our local_hold time is being continulously subtracted based on delta, sort of like a timer.
	# if we're not on the ground, our coyote timer is also being subtracted
	local_hold_time -= delta
	current_coyote_time -= delta
	current_jump_buffer_time -= delta
	current_wall_hug_time -= delta
	if is_invincible == true:
		current_invincibility_time -= delta
	if current_invincibility_time <= 0:
		stop_invincibility()
	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false
	
	if direction != 0:
		animated_sprite.play("Walking")
	else:
		animated_sprite.play("Idle")
	detect_hit_collision()
	# move towards will move us towards a given vector, overtime
	# we are moving from our current x velocity, to the value of max_run * direction. direction will be either -1 or 1 so we're moving left or right
	# and multiplying that -1 or 1 by max_run will determine the top speed that we're moving in a given direction
	# run_accel * delta is the time it takes to move over time, 
	velocity.x = move_toward(velocity.x, current_run * direction, current_run_accel * delta)
	velocity.y = move_toward(velocity.y, current_fall, gravity * delta)

	#move_x(velocity.x * delta, funcref(self, "on_collision_x"))
	# we have to set our global position because this script assumses the hierarchy is an empty node2D as the parent
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
func detect_hit_collision()->void:
	# are we stomping on an enemy? Lets do a little hop if so
	
	for member in CollisionManager.check_actor_group_collision(self, "Enemies", Vector2.DOWN, true):
		velocity.y = jump_force
		# add stomp_hop bool. if stomp_hop is true, start stomp_hop timer
		# if jump button is pressed before stomp_hop_timer hits zero, then we get a BIGGER jump
		# this should be generalized so it can be used for a spring mechanism
		# but the amount of jump the player gets from a spring would be bigger than what they would get from an enemy
	
	# we're colliding with an enemy from ANY other direction, we're in for it...
	var collided_enemies:Array = []
	collided_enemies.append_array(CollisionManager.check_actor_group_collision(self, "Enemies", Vector2.RIGHT, true))
	collided_enemies.append_array(CollisionManager.check_actor_group_collision(self, "Enemies", Vector2.LEFT, true))
	collided_enemies.append_array(CollisionManager.check_actor_group_collision(self, "Enemies", Vector2.UP, true))
	
	for member in collided_enemies:
		take_damage(1, member.position)
		break # we only want to get hurt ONCE even if we're being hit by multiple enemies all at once. Thoug the invincibility flag should prevent this anyway

	pass

func jump_tween()->void:
	tween.interpolate_property(animated_sprite, "scale:x", 0.15, 1,0.5,Tween.TRANS_QUINT,Tween.EASE_OUT)
	tween.interpolate_property(animated_sprite, "scale:y", 2.25, 1,0.5,Tween.TRANS_QUINT,Tween.EASE_OUT)
	tween.start()
	pass

func land_tween()->void:
	tween.interpolate_property(animated_sprite, "scale:x", 2.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
	tween.interpolate_property(animated_sprite, "scale:y", 0.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
	tween.start()
	
	# gotta spawn landing particles
	if LandingParticles2D:

		var instanced_particles = LandingParticles2D.instance()
		var height = animated_sprite.frames.get_frame("Idle", 0).get_height()
		instanced_particles.position =  Vector2(position.x, position.y + (height / 2))

		get_parent().add_child(instanced_particles)
		instanced_particles.emitting = true
	pass



func take_damage(damage: int, attacker_position: Vector2 = Vector2(0,0))->void:
	if is_invincible == true:
		return
	
	current_hp -= damage

	#force_bounce()
	start_invincibility()
	var impulse_direction = attacker_position.direction_to(position)
	# we have the impulse direction we wnat to go,then we have the 20 which is basically the power/speed/ scalar
	velocity.x = impulse_direction.x * 300
	# some damage taken indication, like flashing the sprite and bouncing it, possibly some screen shake
	if current_hp <= 0:
		queue_free()
	#send out a signal telling all liseners that we took some DAMAGE
	emit_signal("took_damage", damage, current_hp, max_hp)
	camera.shake(100, 0.2)
	pass

func start_invincibility()->void:
	current_invincibility_time = MAX_INVINCIBILITY_TIME
	is_invincible = true
	# add some kind of flashing effect or something here
	var damage_flash = animation_player.get_animation("DamageFlash")
	damage_flash.set_loop(true)
	animation_player.play("DamageFlash")
	pass


func stop_invincibility()->void:
	is_invincible = false
	# stop flashing
	animation_player.stop()
	#we need this because stop() wont reset until the next time we hit play()
	#animation_player.seek(0, true)

	pass


func collect_coin(coin_value:int)->void:
	print("GOT A COIN")
	coin_count += coin_value
	# maybe something happens if we collect 100 coins
	emit_signal("collected_coin", coin_count)
	pass

# could pass key type as a parameter. i.e. blue key, red key, etc
func collect_key()->void:
	key_count += 1
	emit_signal("collected_key", key_count)
	pass

# if we can unlock a key block reduce our count by one and return true, otherwise return false
func try_unlock_key_block()->bool:
	if key_count > 0:
		key_count -= 1
		emit_signal("use_key", key_count)
		return true
	else:
		return false
	pass
