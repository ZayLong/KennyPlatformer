extends Actor
class_name MagicBlock

# PROPERTIES ============================================================================
export(int, "Normal","Diamond", "Coin", "Key") var block_item
var coin_reference = preload("res://Props/Coin/Coin.tscn")
var diamond_reference = preload("res://Props/Diamond/Diamond.tscn")
onready var animated_sprite = $AnimatedSprite
onready var item_spawn_position = $ItemSpawnPosition2D
onready var particles = $Particles2D
var has_been_hit:bool = false

# CORE ============================================================================
func _ready():
	add_to_group("Blocks")
	if block_item == 0:
		animated_sprite.play("Active - Normal")
	if block_item == 1:
		animated_sprite.play("Active - Diamond")
	if block_item == 2:
		animated_sprite.play("Active - Coin")
	if block_item == 3:
		animated_sprite.play("Active - Key")
	pass # Replace with function body.

func _process(_delta):
	detect_hit_collision()

func detect_hit_collision()->void:
	# player hit us from the bottom
	if CollisionManager.check_actor_group_collision(self, "Player", Vector2.DOWN) && !has_been_hit:
		process_block()
		has_been_hit = true
		pass
# METHODS ============================================================================
func process_block():
	#unlock key block
	if block_item == 3:
		# maybe some kidn of key unlock effect???
		return
	var item_instance
	# normal block
	if block_item == 0:
		animated_sprite.play("Active - Normal")
		particles.emitting = true
		animated_sprite.visible = false
		hitbox.collidable = false
		return
		
	# spawn a diamond
	if block_item == 1:
		item_instance = diamond_reference.instance()
		animated_sprite.play("Inactive - Diamond")
		
	# spawn a coin
	if block_item == 2:
		item_instance = coin_reference.instance()
		animated_sprite.play("Inactive - Coin")
		
	#spawn the item
	if item_instance != null:
		print("INSTANCE ITEM")
		add_child(item_instance)
		item_instance.position = item_spawn_position.position
		return
	pass # Replace with function body.
