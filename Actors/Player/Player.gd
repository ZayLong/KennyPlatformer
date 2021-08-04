extends KinematicBody2D

class_name PlayerController
# Declare member variables here. Examples:
const UP:Vector2 = Vector2(0, -1)
const GRAVITY:float = 20.0
const MAXFALLSPEED:float = 200.0
const MAXSPEED:float = 80.0
const ACCEL:float = 10.0
const JUMPFORCE:float = 500.0

var motion = Vector2()
var is_facing_right:bool = true
var can_spring_jump:bool = false
var is_invincible:bool = false
var current_hp:float = 5.0
var max_hp:float = 5.0
var coin_count:int = 0
var key_count:int = 0
var is_midair:bool = false
var CURRENT_MAXSPEED:float = MAXSPEED

export(PackedScene) var LandingParticles2D
export(PackedScene) var RunningParticles2D
export(PackedScene) var HitEnemygParticles2D

signal took_damage(damage, current_hp, max_hp)
signal collected_coin(coin_value)
signal collected_key(key_value)
signal use_key(key_value)

func _physics_process(_delta):
	
	motion.y += GRAVITY
	
	# limit our fall velocity
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	# flip the sprite around
	if is_facing_right == true:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false

	motion.x = clamp(motion.x, -CURRENT_MAXSPEED, CURRENT_MAXSPEED)

	if Input.is_action_pressed("ui_right"):
		motion.x += ACCEL
		is_facing_right = true

		$AnimatedSprite.play("Walking")
	elif Input.is_action_pressed("ui_left"):
		motion.x -= ACCEL
		is_facing_right = false

		$AnimatedSprite.play("Walking")
	else:
		# reduces speed by 2% every frame until we are at zero
		motion.x = lerp(motion.x, 0, 0.14)
		if is_on_floor():
			#just ensures we are playing idle animation if were on the ground and not pressing left or right
			$AnimatedSprite.play("Idle")
	
	if is_on_floor() || can_spring_jump:
		if Input.is_action_just_pressed("ui_up"):

			if can_spring_jump:
				motion.y = -(JUMPFORCE + JUMPFORCE*0.2)
				can_spring_jump = false
			else:
				motion.y = -JUMPFORCE
				jump_tween()
	if is_on_floor() && is_midair:
			is_midair = false
			land_tween()
		
	if !is_on_floor():
		if !is_midair:
			is_midair = true
		if motion.y < 0:
			# play jumping animation/tween
			pass
		elif motion.y > 0:
			# play falling animation/tween
			pass
			
	motion = move_and_slide(motion, UP)
	
	# Collision detection loop
	# collision_process()

func collision_process()->void:
	for index in get_slide_count():
		var collision : KinematicCollision2D = get_slide_collision(index)
		if collision:
			if collision.collider.is_in_group("Enemies"):
				
				var reflect = collision.remainder.bounce(collision.normal)
				print(reflect)
				motion = motion.bounce(collision.normal)
				move_and_slide(reflect)
	pass
			#take_damage()

func jump()->void:
	pass

func start_invincibility()->void:
	$InvincibilityTimer.start()
	is_invincible = true
	# add some kind of flashing effect or something here
	var damage_flash = $AnimationPlayer.get_animation("DamageFlash")
	damage_flash.set_loop(true)
	$AnimationPlayer.play("DamageFlash")
	
func take_damage(damage: int, attacker_position: Vector2 = Vector2(0,0))->void:
	if is_invincible == true:
		return
	current_hp -= damage
	CURRENT_MAXSPEED = 500
	#force_bounce()
	start_invincibility()
	var impulse_direction = attacker_position.direction_to(position)
	# we have the impulse direction we wnat to go,then we have the 20 which is basically the power/speed/ scalar
	motion.x  =impulse_direction.x * CURRENT_MAXSPEED
	$ResetMaxSpeedTimer.start()
	# some damage taken indication, like flashing the sprite and bouncing it, possibly some screen shake
	if current_hp <= 0:
		queue_free()
	#send out a signal telling all liseners that we took some DAMAGE
	emit_signal("took_damage", damage, current_hp, max_hp)
	$Camera2D.shake(100, 0.2)
	pass

func collect_coin(coin_value:int)->void:
	coin_count += coin_value
	# maybe something happens if we collect 100 coins
	emit_signal("collected_coin", coin_count)
	pass

# could pass key type as a parameter. i.e. blue key, red key, etc
func collect_key()->void:
	key_count += 1
	emit_signal("collected_key", key_count)
	pass

# we landed on something thats making us bounce up
func force_bounce()->void:
	motion.y = -(JUMPFORCE/1.5)
	jump_tween()
	pass

func jump_tween()->void:
	$Tween.interpolate_property($AnimatedSprite, "scale:x", 0.15, 1,0.5,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$Tween.interpolate_property($AnimatedSprite, "scale:y", 2.25, 1,0.5,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$Tween.start()

func land_tween()->void:

	$Tween.interpolate_property($AnimatedSprite, "scale:x", 2.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$Tween.interpolate_property($AnimatedSprite, "scale:y", 0.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$Tween.start()
	
	# gotta spawn landing particles
	if LandingParticles2D:
		var instanced_particles = LandingParticles2D.instance()
		instanced_particles.position =  $ParticlePosition2D.global_position
		get_parent().add_child(instanced_particles)
		instanced_particles.emitting = true


# if we can unlock a key block reduce our count by one and return true, otherwise return false
func try_unlock_key_block()->bool:
	if key_count > 0:
		key_count -= 1
		emit_signal("use_key", key_count)
		return true
	else:
		return false
# if our feet touch an enemies weak point (usually the top) then we bounce, and they die
# also if our feet touch a spring, we bounch and we can spring jump
func _on_FeetArea2D_area_entered(area: Area2D)->void:
	# give us a little "hop" when we land on an enemy
	if area.is_in_group("Enemy Weak Point"):
		force_bounce()
		$Camera2D.shake(100, 0.2)
		if HitEnemygParticles2D:
			var instanced_particles = HitEnemygParticles2D.instance()
			instanced_particles.position =  $ParticlePosition2D.global_position
			get_parent().add_child(instanced_particles)
			instanced_particles.emitting = true
	if area.name == "BounceToleranceArea2D":
		can_spring_jump = true


func _on_FeetArea2D_area_exited(area:Area2D)->void:

	if area.name == "BounceToleranceArea2D":
		can_spring_jump = false

# our invincibility ran out
func _on_InvincibilityTimer_timeout()->void:
	is_invincible = false
	# stop flashing
	$AnimationPlayer.stop()
	#we need this because stop() wont reset until the next time we hit play()
	$AnimationPlayer.seek(0, true)
	pass # Replace with function body.


func _on_ResetMaxSpeedTimer_timeout()->void:
	CURRENT_MAXSPEED = MAXSPEED
	pass # Replace with function body.
