extends Actor
class_name Enemy

# PROPERTIES ============================================================================
export var health: int = 1
export var coin_value:int = 5

onready var tween:Tween = $Tween
onready var animated_sprite:AnimatedSprite = $AnimatedSprite



# CORE ============================================================================
func _ready()->void:
	add_to_group("Enemies")
	tween.interpolate_property(animated_sprite, "scale:x", 2.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
	tween.interpolate_property(animated_sprite, "scale:y", 0.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
	tween.connect("tween_all_completed", self, "_on_tween_all_completed")



# METHODS ============================================================================
func detect_hit_collision()->void:
	# is the player stepping on us?
	if CollisionManager.check_actor_group_collision(self, "Player", Vector2.UP):
		hit_by_player_collision()
		pass

func hit_by_player_collision()->void:
		# player hit us on the head, so we should 
		# execute a tween for us getting hurt
		# subtract HP from ourselves
		# check if we're dead
		take_damage_routine()
		pass
	
func take_damage_routine()->void:
	#instance a hit effect

	tween.start()
	pass

func _on_tween_all_completed()->void:
	health -= 1
	if health <= 0:
		death_routine()
	pass

func death_routine()->void:
	# need some nice explosion 
	pass
