extends Solid

onready var tween = $Tween

export var on_time : float = 1
export var off_time : float = 3
var fall_through = false

func _ready():
	init_tween()
	
func init_tween():
	tween.interpolate_property(self, "fall_through", false, true, on_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	tween.interpolate_property(self, "fall_through", true, false, off_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, on_time)
	tween.repeat = true
	tween.connect("tween_step", self, "on_tween_step")
	tween.start()

func on_tween_step(_object, _key, _elapsed, _value):
	hitbox.collidable = fall_through
