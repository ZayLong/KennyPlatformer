extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# if the player enters the area, we spring em
#func _on_SpringArea2D_body_entered(body: PhysicsBody2D) -> void:
#	var player := body as PlayerController
#	if not player:
#		return
#	player.force_bounce()
#	pass # Replace with function body.


func _on_SpringArea2D_area_entered(area: Area2D):
	var player = area.get_parent()
	if player is PlayerController:
		player.force_bounce()
		
	pass # Replace with function body.
