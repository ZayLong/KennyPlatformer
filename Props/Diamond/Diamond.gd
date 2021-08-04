extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body: PhysicsBody2D)->void:
	var player := body as PlayerController
	if not player:
		return
	# some method to increase HP or whatever else diamonds do
	queue_free()
	pass # Replace with function body.
