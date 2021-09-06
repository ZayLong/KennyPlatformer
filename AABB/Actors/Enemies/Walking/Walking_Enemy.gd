extends Enemy
class_name WalkingEnemy

# PROPERTIES ============================================================================
onready var edgeDetection:HitBox = $EdgeDetectionHitbox
const max_run:int = 50
var current_run:int = max_run

const max_run_accel:int = 150
var current_run_accel:int = max_run_accel

const max_gravity:int = 1000
var gravity:int = max_gravity

const max_fall: int = 260
var current_fall:int = max_fall

var direction:int = -1
# CORE ============================================================================

func _process(delta:float)->void:

	if CollisionManager.check_hitbox_against_tile(edgeDetection,Vector2.ZERO) == false:
		if direction > 0:
			direction = -1
		else:
			direction = 1
		
		edgeDetection.x = abs(edgeDetection.x) * direction
		on_collision_x() # so we can STOP ON DIME LOL

	
	if direction > 0:
		animated_sprite.flip_h = true
	elif direction < 0:
		animated_sprite.flip_h = false
	
	detect_hit_collision()
	velocity.x = move_toward(velocity.x, current_run * direction, current_run_accel * delta)
	velocity.y = move_toward(velocity.y, current_fall, gravity * delta)
	
	move_x(velocity.x * delta, funcref(self, "on_collision_x"))
	move_y(velocity.y * delta, funcref(self, "on_collision_y"))

# METHODS ============================================================================
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
