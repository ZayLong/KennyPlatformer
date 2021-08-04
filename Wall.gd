extends Node2D
export var jump_through = false
onready var hitbox = $Hitbox

func _ready()->void:
	add_to_group("Walls")
