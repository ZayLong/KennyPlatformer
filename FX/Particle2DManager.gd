extends Particles2D

signal done_emitting

func _process(delta):
	if not emitting:
		emit_signal("done_emitting")
		queue_free()
