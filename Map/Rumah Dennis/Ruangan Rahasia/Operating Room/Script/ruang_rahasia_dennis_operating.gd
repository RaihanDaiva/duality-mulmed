extends Node2D

@onready var tilemap = $Environment/TileMap  # Path ke TileMap Anda
@onready var camera = $Player/Camera2D

#Untuk navigasi ruangan harus menambahkan ini
func _ready():
	#State.entered_operating_room = true
	#if State.entered_operating_room:
	print(State.current_subscene)
	if State.current_subscene == "scene18":
		State.current_subscene = "scene19"
	
	if State.current_subscene == "scene19":
		$Grey/InteractionArea/CollisionShape2D.disabled = true
		_talk()
		#State.current_subscene = "scene19"
	elif State.current_subscene == "scene20":
		if !State.quest_half_body:
			$Grey/InteractionArea/CollisionShape2D.disabled = true
		else:
			$Grey/InteractionArea/CollisionShape2D.disabled = false
		
	print(State.current_subscene)
	
	auto_setup_camera_from_tilemap()
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)

func _talk():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	player.can_move = false
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		
	await get_tree().create_timer(1).timeout
	DialogueManager.show_dialogue_balloon(
		load("res://Scene/Scene 19/Dialogue/grey.dialogue"),
		"start"
	)
	
func _on_dialogue_finished(resource):
	State.current_subscene = "scene20"
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	player.can_move = true
	
	#$"CanvasLayer/Fade Transition2".visible = true
	#$"CanvasLayer/Fade Transition2/AnimationPlayer".play("fade_in")
	

func _on_level_spawn(destination_tag: String):
	var door_path = "Doors/Door_" + destination_tag
	var door = get_node(door_path) as Door
	NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)

func auto_setup_camera_from_tilemap():
	if not tilemap or not camera:
		return
	
	# Dapatkan area yang digunakan tilemap
	var used_rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size
	
	# Hitung batas dalam pixel
	var map_start = used_rect.position * tile_size
	var map_end = used_rect.end * tile_size
	
	# Set camera limits
	camera.limit_left = int(map_start.x)
	camera.limit_top = int(map_start.y)
	camera.limit_right = int(map_end.x)
	camera.limit_bottom = int(map_end.y)
	
	print("Camera limits set to: ", map_start, " -> ", map_end)
