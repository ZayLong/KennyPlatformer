tool
extends Node2D

export var x:int = 0
export var y:int = 0
export var width:int = 16
export var height:int = 16
export var color:Color = Color(0,0,1,0.5)
export var disable_color:Color = Color(0,0,1,0.5)

onready var original_color:Color = color
var m_collidable = true
var collidable setget set_collidable, get_collidable
var left setget ,get_left
var right setget ,get_right
var top setget ,get_top
var bottom setget ,get_bottom

func set_collidable(value)->void:
	if value:
		color = original_color
	else:
		color = disable_color
	m_collidable = value
	
func get_collidable():
	return m_collidable

func get_left()->float:
	return global_position.x + x
	pass

func get_right()->float:
	return global_position.x + x + width
	pass
func get_top()->float:
	return global_position.y + y
	pass
func get_bottom()->float:
	return global_position.y + y + height
	pass

func _draw()->void:
	draw_rect(Rect2(x,y,width,height), color)
	pass

func _physics_process(_delta)->void:
	update()
	pass

func intersects(other, offset)->bool:
	if !self.collidable || !other.collidable:
		return false
	else:
		return ((self.right + offset.x) > other.left && (self.left + offset.x) < other.right 
	&& (self.bottom + offset.y) > other.top && (self.top + offset.y) < other.bottom)
