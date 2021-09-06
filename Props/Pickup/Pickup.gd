extends Actor
class_name Pickup

# PROPERTIES ============================================================================
onready var animated_sprite:AnimatedSprite = $AnimatedSprite

export(int,"Diamond", "Coin", "Key") var pickup_item
export var PickupEffect:PackedScene

const DEATH_DELAY_TIME_MAX:float = 0.5
var death_delay_time:float = 0.0
var been_picked_up:bool = false
# CORE ============================================================================
func _ready()->void:
	add_to_group("Pickups")
	
	if pickup_item == 0:
		animated_sprite.play("Diamond")
	elif pickup_item == 1:
		animated_sprite.play("Coin")
	elif pickup_item == 2:
		animated_sprite.play("Key")
	pass

func _process(_delta:float)->void:
	detect_collisions()
	pass
# METHODS ============================================================================

func detect_collisions()->void:
	var result:Array = CollisionManager.check_actor_group_collision(self, "Player", Vector2.ZERO, true)
	if result.size() > 0 && !been_picked_up:
		if result.front() is PlatformerPlayer:
			pickup_effect(result.front())
	pass

func pickup_effect(player:PlatformerPlayer)->void:

	
	been_picked_up = true
	
	
	match pickup_item:
		0: #diamond
			continue
		1: #coin
			player.collect_coin(1)
		2: #key
			player.collect_key()
		
	if PickupEffect:
		var instanced_particles = PickupEffect.instance()

		get_parent().add_child(instanced_particles)
		instanced_particles.emitting = true
		var error = instanced_particles.connect("done_emitting", self, queue_free())
		if error:
			print(error)
	else:
		queue_free()
	pass
