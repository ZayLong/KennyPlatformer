extends Node2D
# PROPERTIES ============================================================================
var tile_hitbox:HitBox
var base_tilemap:TileMap

# METHODS ============================================================================

# run a check against a defined group of members
# members have to have a hitbox property
# if the intersect is true, add it to an array
# at the end return the array
# add an optional parameter find_one
# this will return an array containing one element (if any)
func check_actor_group_collision(entity:Actor, group:String, offset:Vector2, find_one:bool = false)->Array:
	var group_members = get_tree().get_nodes_in_group(group)
	var coliding_members:Array = []
	for member in group_members: 
		if "hitbox" in member:
			if member != entity:
				if entity.hitbox.intersects(member.hitbox, offset):
					coliding_members.append(member)
					if find_one:
						return coliding_members
	return coliding_members

func check_walls_collision(entity:Actor, offset:Vector2)->bool:
	var walls = get_tree().get_nodes_in_group("Walls")
	for wall in walls: 
		if wall.jump_through:
			# should we just make it sot hat is_riding is always going to have an offset vector of DOWN???/
			if offset == Vector2.DOWN && entity.is_riding(wall, offset):
				return true
		elif entity.hitbox.intersects(wall.hitbox, offset):
			return true
	return false
# solid, intangible, pass_through, interactable are the named ids for our tiles
func check_tiles_collision(entity:Actor, offset:Vector2)->bool:
	# jump corner correction is a feature specific to a player object
	# i feel like putting this here may be a seperation of concerns issue
	# but for the time being this is the best place i can think to put it.
	var potential_jump_corner_tiles:Array
	var collided_with_solid_tile:bool = false
	
	if !base_tilemap:
		base_tilemap = get_tree().get_nodes_in_group("BaseTileMap").front() as TileMap
		
	# check interaction with solid tiles
	var solid_tiles:Array = base_tilemap.get_used_cells_by_id(base_tilemap.tile_set.find_tile_by_name("solid"))
	for tile in solid_tiles:
		tile = tile as Vector2
		var global_tile_pos:Vector2 = base_tilemap.map_to_world(tile)
		if entity.hitbox.intersects_tile(global_tile_pos, base_tilemap.cell_size, offset):
			collided_with_solid_tile = true
			# we only will potentially jump correct if the entity is a player, and if said player hit its head against a tile
			if entity is PlatformerPlayer && offset == Vector2.UP:
				potential_jump_corner_tiles.append(tile)
			
	# we will only attempt a jump correction if we're colliding with ONE tile from above
	# anything else implies we're hitting two tiles at once, implying we are NOT at a corner
	if potential_jump_corner_tiles.size() == 1:
		var tile = potential_jump_corner_tiles.front()
		var global_tile_pos:Vector2 = base_tilemap.map_to_world(tile)
		entity = entity as PlatformerPlayer
		entity.jump_corner_correction(global_tile_pos, base_tilemap.cell_size, Vector2.UP)
		
	if collided_with_solid_tile:
		return true
	# check interaction with tiles we can pass through from underneath and drop down from
	var pass_through_tiles:Array = base_tilemap.get_used_cells_by_id(base_tilemap.tile_set.find_tile_by_name("pass_through"))
	for tile in pass_through_tiles:
		tile = tile as Vector2
		var global_tile_pos:Vector2 = base_tilemap.map_to_world(tile)
		if offset == Vector2.DOWN &&entity.is_riding_tile(global_tile_pos, base_tilemap.cell_size, offset):
			return true
	
	# all other conditions have failed so  return false
	return false
	pass

# made this so we can pass a generic hitbox into the collision manager, insteaed of always having to pass an actor
func check_hitbox_against_tile(hitbox:HitBox, offset:Vector2)->bool:
	if !base_tilemap:
		base_tilemap = get_tree().get_nodes_in_group("BaseTileMap").front() as TileMap

	# check interaction with solid tiles
	var solid_tiles:Array = base_tilemap.get_used_cells_by_id(base_tilemap.tile_set.find_tile_by_name("solid"))
	var pass_through_tiles:Array = base_tilemap.get_used_cells_by_id(base_tilemap.tile_set.find_tile_by_name("pass_through"))
	solid_tiles.append_array(pass_through_tiles)
	for tile in solid_tiles:
		tile = tile as Vector2
		var global_tile_pos:Vector2 = base_tilemap.map_to_world(tile)
		if hitbox.intersects_tile(global_tile_pos, base_tilemap.cell_size, offset):
			return true
	return false
	pass

func get_all_actors():
	return get_tree().get_nodes_in_group("Actors")
	
func get_all_riding_actors(solid):
	var riders : Array = []
	var actors = get_tree().get_nodes_in_group("Actors")
	for actor in actors:
		if actor.is_riding(solid, Vector2.DOWN):
			riders.append(actor)
	return riders
