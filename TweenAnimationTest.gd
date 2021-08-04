extends AnimatedSprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#$Tween.interpolate_property(self, "scale:x", 0.5, 1.5,5,Tween.TRANS_EXPO,Tween.EASE_OUT)
	var anim = get_node("AnimationPlayer").get_animation("Flashing")
	anim.set_loop(true)
	get_node("AnimationPlayer").play("Flashing")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("ui_left"):

			#$Tween.interpolate_property(self, "scale:x", 2.15, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
			#$Tween.interpolate_property(self, "scale:y", 0.25, 1,0.4,Tween.TRANS_QUINT,Tween.EASE_OUT)
			$Tween.interpolate_property(self, "scale:x", 0.15, 1,0.3,Tween.TRANS_QUINT,Tween.EASE_OUT)
			$Tween.interpolate_property(self, "scale:y", 2.25, 1,0.3,Tween.TRANS_QUINT,Tween.EASE_OUT)
			
			#$Tween.interpolate_property(self, "position:y",position.y, position.y+(position.y *0.2) ,0.2,Tween.TRANS_QUINT,Tween.EASE_OUT)
			$Tween.start()
		if event.is_action_pressed("ui_right"):
			print("LANDING")
			$AnimationPlayer.stop()
			#we need this because stop() wont reset until the next time we hit play()
			$AnimationPlayer.seek(0, true)
			$Tween.start()

