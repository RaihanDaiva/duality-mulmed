extends Node2D

@onready var label = $Label

const base_text = "[E] to "

var active_areas = []
var can_interact = true

# Gunakan property dengan getter untuk memastikan player selalu valid
var player:
	get:
		if not is_instance_valid(_cached_player):
			_cached_player = get_tree().get_first_node_in_group("player")
		return _cached_player

var _cached_player = null

func _ready():
	# Cache player saat ready
	_cached_player = get_tree().get_first_node_in_group("player")

func register_area(area: InteractionArea):
	active_areas.push_back(area)

func unregister_area(area: InteractionArea):
	var index = active_areas.find(area)
	if index != -1:
		active_areas.remove_at(index)

func _process(delta: float) -> void:
	# Cek player valid sebelum proses
	if not player:
		label.hide()
		return
	
	if active_areas.size() > 0 && can_interact:
		# Bersihkan null areas sebelum sort
		active_areas = active_areas.filter(func(area): return is_instance_valid(area))
		
		if active_areas.size() == 0:
			label.hide()
			return
		
		active_areas.sort_custom(sort_by_distance_to_player)
		label.text = base_text + active_areas[0].action_name
		label.global_position = active_areas[0].global_position
		label.global_position.y -= 15
		label.global_position.x -= label.size.x / 2
		label.show()
	else:
		label.hide()

func sort_by_distance_to_player(area1, area2):
	# Safety check: pastikan player dan areas valid
	if not player or not is_instance_valid(area1) or not is_instance_valid(area2):
		return false
	
	var area1_to_player = player.global_position.distance_to(area1.global_position)
	var area2_to_player = player.global_position.distance_to(area2.global_position)
	
	return area1_to_player < area2_to_player  # PENTING: return comparison result!

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0 && is_instance_valid(active_areas[0]):
			can_interact = false
			label.hide()
			
			await active_areas[0].interact.call()
			
			can_interact = true
