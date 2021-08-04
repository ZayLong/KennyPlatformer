extends StaticBody2D
# What item should be inside the block
export(int, "Normal","Diamond", "Coin", "Key") var block_item
var coin_reference = preload("res://Props/Coin/Coin.tscn")
var diamond_reference = preload("res://Props/Diamond/Diamond.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	if block_item == 0:
		$AnimatedSprite.play("Active - Normal")
	if block_item == 1:
		$AnimatedSprite.play("Active - Diamond")
	if block_item == 2:
		$AnimatedSprite.play("Active - Coin")
	if block_item == 3:
		$AnimatedSprite.play("Active - Key")
	pass # Replace with function body.

# we are hit from the botton by the player
func _on_TriggerArea2D_body_entered(body: PhysicsBody2D)->void:
	var player := body as PlayerController
	if not player:
		return
	# What happens after we hit the block as long as its not a key block
	if block_item != 3:
		break_block()
	
	
	
	pass # Replace with function body.

func break_block():
	$Tween.interpolate_property(self, "scale:x", 0.15, 1,0.2,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$Tween.interpolate_property(self, "scale:y", 2.25, 1,0.2,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$Tween.interpolate_property(self, "position:y",position.y, position.y+(position.y *0.05) ,0.2,Tween.TRANS_QUINT,Tween.EASE_OUT)
	$Tween.start()

# check if player collides with us and if so  check if they have a key available. if so we "unlock" and disappear
func _on_KeyArea2D_body_entered(body: PhysicsBody2D)->void:
	var player := body as PlayerController
	if not player:
		return
	
	# we are currently a key block
	if block_item == 3:
		var result = player.try_unlock_key_block()
		if result == true:
			#should have some kind of animation for getting rid of the key block
			$AnimatedSprite.visible = false
			$CollisionShape2D.set_deferred("disabled", true)
	pass # Replace with function body.


func _on_Tween_tween_all_completed():
	if block_item == 3:
		# maybe some kidn of key unlock effect???
		return
	var item_instance
	if block_item == 0:
		$AnimatedSprite.play("Active - Normal")
		$Particles2D.emitting = true
		$AnimatedSprite.visible = false
		$CollisionShape2D.set_deferred("disabled", true)
		return
		
		
	if block_item == 1:
		item_instance = diamond_reference.instance()
		$AnimatedSprite.play("Inactive - Diamond")
		return
	if block_item == 2:
		item_instance = coin_reference.instance()
		$AnimatedSprite.play("Inactive - Coin")
		return
		
	if item_instance != null:
		add_child(item_instance)
		item_instance.position = $ItemSpawnPosition2D.position
		return
	pass # Replace with function body.
