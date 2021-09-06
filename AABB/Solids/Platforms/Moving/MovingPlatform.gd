extends Solid

onready var tween = $Tween
onready var start = global_position
onready var follow = global_position
export var offset = Vector2.ZERO
export var time = 2
export var delay = 1
func _ready():
	init_tween()
	
func init_tween():
	tween.interpolate_property(self, "follow", start, start + offset, time,Tween.TRANS_QUAD,Tween.EASE_OUT, delay)
	tween.interpolate_property(self, "follow", start + offset, start, time,Tween.TRANS_QUAD,Tween.EASE_OUT, time + (2 * delay))
	tween.repeat = true
	tween.connect("tween_step", self, "_on_tween_step")
	tween.start()


func _on_tween_step(_object, _key, _elapsed, _value):
	move_rider_x(follow.x - (global_position.x + remainder.x))
	move_rider_y(follow.y - (global_position.y + remainder.y))
	pass
