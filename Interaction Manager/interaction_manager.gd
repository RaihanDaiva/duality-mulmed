extends Node2D

@onready var label = $Label

const base_text = "[E] to "
var active_areas = []
var can_interact = true
var dialogue_active = false  # Flag untuk track dialogue

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
	
	# Connect ke DialogueManager signal untuk track dialogue state
	if DialogueManager.has_signal("dialogue_started"):
		DialogueManager.dialogue_started.connect(_on_dialogue_started)
	if DialogueManager.has_signal("dialogue_ended"):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

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
	#print("interact: ", can_interact)
	#print("dialogue: ", dialogue_active)
	# Tampilkan label hanya jika bisa interact DAN tidak ada dialogue aktif
	if active_areas.size() > 0 && can_interact && not dialogue_active:
		#print("area aktif")
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
	
	return area1_to_player < area2_to_player

func _input(event: InputEvent) -> void:
	# Block interaction jika dialogue sedang aktif
	if dialogue_active:
		return
	
	if event.is_action_pressed("interact") && can_interact:
		if active_areas.size() > 0 && is_instance_valid(active_areas[0]):
			can_interact = false
			dialogue_active = true  # Set flag sebelum interact
			label.hide()
			
			# Call interaction
			if active_areas[0].interact.is_valid():
				await active_areas[0].interact.call()
			
			# Reset setelah dialogue selesai
			# (akan di-reset oleh signal dialogue_ended juga)
			can_interact = true
			dialogue_active = false

func _on_dialogue_started(resource):
	# Callback saat dialogue dimulai
	dialogue_active = true
	can_interact = false
	label.hide()

func _on_dialogue_ended(resource):
	# Callback saat dialogue selesai
	dialogue_active = false
	can_interact = true
