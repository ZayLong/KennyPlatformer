extends HBoxContainer
var heart_container_atlas_reference = preload("res://GUI/HeartContainer_data.tres")
var heart_containers = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	# get rid of placeholder hearts
	for n in get_children():
		remove_child(n)
		n.free()
	repaint_heart_containers(2.5, 5)
	
	
# max hp should always be an int
func repaint_heart_containers(current_hp, max_hp):
	# check if the number of heart containers we have matches what our max_hp is
	if heart_containers.size() != max_hp:
		var difference = abs(heart_containers.size() - max_hp)
		
		#we have too many heart containers, lets get rid of some
		if heart_containers.size() > max_hp:
			for index in difference:
				heart_containers.pop_back()
		# we dont have enough heart containers, lets add some
		elif heart_containers.size() < max_hp:
			for index in difference:
				var heart_container = TextureRect.new()
				add_child(heart_container)
				heart_containers.append(heart_container)
	
	# now that we have the corret number of heart containers, we need to iterate 
	# over them and adjust whether or not they should be full/partial/empty
	for index in heart_containers.size():

		var heart_container_ref = heart_containers[index]

		if (index+1) < ceil(current_hp):
			heart_container_atlas_reference.region.position.x = 72 # full heart
			heart_container_ref.texture = heart_container_atlas_reference.duplicate()
			continue
		elif (index+1) > ceil(current_hp):
			heart_container_atlas_reference.region.position.x = 108 # empty heart
			heart_container_ref.texture = heart_container_atlas_reference.duplicate()
			continue
		
		if (index+1) == ceil(current_hp):
			if fmod(current_hp ,ceil(current_hp)) == 0:
				heart_container_atlas_reference.region.position.x = 72
				heart_container_ref.texture = heart_container_atlas_reference.duplicate()
				continue
			else:
				heart_container_atlas_reference.region.position.x = 90 # half full heart
				heart_container_ref.texture = heart_container_atlas_reference.duplicate()
				continue
	pass
