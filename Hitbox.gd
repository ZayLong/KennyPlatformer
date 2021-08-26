tool
extends Node2D
class_name HitBox

export var x:int = 0
export var y:int = 0
export var width:int = 16
export var height:int = 16
export var color:Color = Color(0,0,1,0.5)
export var disable_color:Color = Color(0,0,1,0.5)

onready var original_color:Color = color
var m_collidable:bool = true
var collidable setget set_collidable, get_collidable
var left setget ,get_left
var right setget ,get_right
var top setget ,get_top
var bottom setget ,get_bottom



func _init(init_x:int = x, init_y:int = y, init_width:int = width, init_height:int = height):
	x = init_x
	y = init_y
	width = init_width
	height = init_height
	pass

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
	update() # update func for draw, wish this method name was more specific
	pass

# check if a single point is within the bounds of our hitbox
# cool idea i had for more presise AABB collision detection. 
# i'd like to elaborate more on this idea with quadrant within a hitbox too eventually
# got the formula from this stackoverflow: https://stackoverflow.com/a/37865332
func intersects_point(point:Vector2)->bool:
	var left_top:Vector2 = Vector2(self.left, self.top) # A
	var right_top:Vector2 = Vector2(self.right, self.top) # B
	var right_bottom:Vector2 = Vector2(self.right, self.bottom) # C
	var left_bottom:Vector2 = Vector2(self.left, self.bottom) # D
	
	# subtracting gives the vector between two points
	var AB:Vector2 = Vector2(right_top.x - left_top.x, right_top.y - left_top.y)
	var BC:Vector2 = Vector2(right_bottom.x - right_top.x, right_bottom.y - right_top.y)
	var AP:Vector2 = Vector2(point.x - left_top.x, point.y - left_top.x)
	var BP:Vector2 = Vector2(point.x - right_top.x, point.y - right_top.y)
	
	# get our scalar values
	var dotABAP = AB.dot(AP)
	var dotABAB = AB.dot(AB)
	var dotBCBP = BC.dot(BP)
	var dotBCBC = BC.dot(BC)
	
	# evaluate
	return 0 <= dotABAP && dotABAP <= dotABAB && 0 <= dotBCBP && dotBCBP <= dotBCBC
	pass

# similar to regular intersects, but does the AABB calculation for a tile which does not have a hitbox
func intersects_tile(tile_pos:Vector2, cell_size:Vector2, offset:Vector2)->bool:
	var tile_right = tile_pos.x + cell_size.x
	var tile_left  = tile_pos.x
	var tile_bottom = tile_pos.y + cell_size.y
	var tile_top = tile_pos.y 
	return ((self.right + offset.x) > tile_left && (self.left + offset.x) < tile_right 
	&& (self.bottom + offset.y) > tile_top && (self.top + offset.y) < tile_bottom)

func intersects(other:HitBox, offset:Vector2)->bool:
	if !self.collidable || !other.collidable:
		return false
	else:
		return ((self.right + offset.x) > other.left && (self.left + offset.x) < other.right 
	&& (self.bottom + offset.y) > other.top && (self.top + offset.y) < other.bottom)
