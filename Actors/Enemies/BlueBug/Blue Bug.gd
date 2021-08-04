extends KinematicBody2D

# PROPERTIES -------------------------------------------------------------------------
export var health:int = 1
export var spikeEnemy:bool = false

# Platform based vars
const UP:Vector2 = Vector2(0, -1)
const GRAVITY:float = 20.0
const MAXFALLSPEED:float = 200.0
const MAXSPEED:float = 20.0
const ACCEL:float = 10.0
const JUMPFORCE:float = 500.0

var motion:Vector2 = Vector2()
var is_facing_right:bool = true

enum STATES {MOVE_LEFT, MOVE_RIGHT, HURT, DEAD}
var CURRENT_STATE


var time:float = 0

# CORE ---------------------------------------------------------------------------------------------

func _ready()->void:
	CURRENT_STATE = STATES.MOVE_LEFT


func _physics_process(_delta)->void:
	execute_physics(_delta)
	pass

# METHODS --------------------------------------------------------------------------------------------------------

func execute_physics(_delta)->void:
	_flip_sprite()
	_pitfall_check()
	_in_air_actions()
	_ground_movement()
	_handle_collision()
	pass

# collide via KinematicBody and if we encounter the player damage him.
func _handle_collision()->void:
	for index in get_slide_count():
		var collision = get_slide_collision(index)
		if collision.collider.name == "Player":
			collision.collider.take_damage(1, position)
	pass


func _flip_sprite()->void:
	if is_facing_right == true:
		$AnimatedSprite.flip_h = true
	else:
		$AnimatedSprite.flip_h = false
	pass

func _ground_movement()->void:
	motion.y += GRAVITY
	
	# limit our fall velocity
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	
	# acceleration/deceleration clamp
	motion.x = clamp(motion.x, -MAXSPEED, MAXSPEED)
	
	# left right movement
	if CURRENT_STATE == STATES.MOVE_RIGHT:
		motion.x += ACCEL
		is_facing_right = true
		$AnimatedSprite.play("Walking")
	elif CURRENT_STATE == STATES.MOVE_LEFT:
		motion.x -= ACCEL
		is_facing_right = false
		$AnimatedSprite.play("Walking")
	else:
		# reduces speed by 2% every frame until we are at zero
		motion.x = lerp(motion.x, 0, 0.14)
		if is_on_floor():
			#just ensures we are playing idle animation if were on the ground and not pressing left or right
			$AnimatedSprite.play("Idle")
			
	
	# this bit actually moves the character
	motion = move_and_slide(motion, UP)

	pass

# raycast check if  we're near an edge, switch directions if so
func _pitfall_check()->void:
	if !$RayCast2D.is_colliding():
		if is_facing_right == true:
			CURRENT_STATE = STATES.MOVE_LEFT
			$RayCast2D.position.x = -8
			#$RayCast2D.force_raycast_update()
		else:
			CURRENT_STATE = STATES.MOVE_RIGHT
			$RayCast2D.position.x = 8
			#$RayCast2D.force_raycast_update()	
	pass


# if we are in mid air, what should we do if we're ascending, vs descending
func _in_air_actions()->void:
	if !is_on_floor():
		if motion.y < 0:
			# play jumping animation/tween
			pass
		elif motion.y > 0:
			# play falling animation/tween
			pass
	pass
	
func take_damage()->void:
	# we could have some kind of burst effect here like we explode when we die with nuts and bolts 
	health -= 1
	if health <= 0:
		queue_free()
	pass

# were we attacked by the players feet? If so we're in trouble...
func got_attacked(area:Area2D)->void:
	if area.name == "FeetArea2D":
		$Tween.interpolate_property($AnimatedSprite, "scale:x", 2.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
		$Tween.interpolate_property($AnimatedSprite, "scale:y", 0.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
		$Tween.start()

	pass

# SIGNALS -------------------------------------------------------------------------------------------------------------------

# we're done getting squished, lets die lol
func _on_Tween_tween_all_completed()->void:
	# we could have some kind of burst effect here like we explode when we die with nuts and bolts 
	take_damage()
	pass # Replace with function body.


# someone entered our weak point!
func _on_DamageArea2D_area_entered(area:Area2D)->void:
	got_attacked(area)
	pass # Replace with function body.


