extends Node2D


# PROPERTIES ==========================================================================

# CORE ==========================================================================

func _ready()->void:
	if get_node_or_null("Player"):
		var _took_damage_signal = $Player.connect("took_damage", self, "_on_Player_take_damage")
		var _collected_coin_signal = $Player.connect("collected_coin", self, "_on_Player_collect_coin")
		var _collected_key_signal = $Player.connect("collected_key", self, "_on_Player_collect_key")
		var _use_key_signal = $Player.connect("use_key", self, "_on_Player_use_key")
		if get_node_or_null("HUD"):
			$HUD/MarginContainer/HParentContainer/HeartContainers.repaint_heart_containers($Player.current_hp, $Player.max_hp)
	pass # Replace with function body.

# METHODS ==========================================================================
func new_game()->void:
	# when we load up the level scene, we should then try to get the UI
	pass

func load_game()->void:
	
	pass

func game_over()->void:
	pass

# EVENTS =======================================================================================
func _on_Player_take_damage(_damage_taken, current_hp, max_hp)->void:
	if get_node_or_null("HUD"):
		$HUD/MarginContainer/HParentContainer/HeartContainers.repaint_heart_containers(current_hp, max_hp)
	
	pass

func _on_Player_collect_coin(coin_value:int)->void:
	if get_node_or_null("HUD"):
		$HUD/MarginContainer/HParentContainer/CoinCounter.repaint_coin_counter(coin_value)
	pass

func _on_Player_collect_key(key_value:int)->void:
	if get_node_or_null("HUD"):
		$HUD/MarginContainer/HParentContainer/KeyCounter.repaint_key_counter(key_value)
	pass

func _on_Player_use_key(key_value:int)->void:
	if get_node_or_null("HUD"):
		$HUD/MarginContainer/HParentContainer/KeyCounter.repaint_key_counter(key_value)
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
