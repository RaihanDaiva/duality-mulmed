extends Node2D

@onready var tilemap = $Environment/TileMap  # Path ke TileMap Anda
@onready var camera = $Player/Camera2D
var quest_title_instance

#Untuk navigasi ruangan harus menambahkan ini
func _ready():
	State.current_subscene = "scene20"
	var quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
	quest_title_instance = quest_title.instantiate()
	add_child(quest_title_instance)
	if State.current_subscene == "scene7":
		change_quest_title("Ke Ruangan Dennis")
	elif State.current_subscene == "scene8":
		if !State.quest_chair_done:
			change_quest_title("Ke Ruang Rapat")
		else:
			change_quest_title("Ke Luar Kantor")
	elif State.current_subscene == "scene9":
		State.current_subscene = "scene10"
	elif State.current_subscene == "scene10":
		if !State.puzzle_scene10:
			change_quest_title("Ke Ruangan Dennis")
		else:
			change_quest_title("Ke Luar Kantor")
	elif State.current_subscene == "scene14":
		if !State.puzzle_scene14:
			change_quest_title("Ke Ruangan Dennis")
		else:
			change_quest_title("Ke Luar Kantor")
	elif State.current_subscene == "scene15":
		change_quest_title("Ke Luar Kantor")
	elif State.current_subscene == "scene20":
		$"CanvasLayer/Fade Transition2".visible = true
		$"CanvasLayer/Fade Transition2/AnimationPlayer".play("fade_out")
		
		var player = get_tree().get_first_node_in_group("player")
		if not player:
			return
		$Player.visible = false
		player.can_move = false
		player.direction = Vector2.ZERO
		
		$Grey.visible = true
		_talk()
	
	auto_setup_camera_from_tilemap()
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)

func _talk():
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		
	await get_tree().create_timer(1).timeout
	DialogueManager.show_dialogue_balloon(
		load("res://Scene/Scene 21/grey.dialogue"),
		"start"
	)
	
func _on_dialogue_finished(resource):
	$"CanvasLayer/Fade Transition2".visible  = true
	$"CanvasLayer/Fade Transition2/AnimationPlayer".play("fade_in")
	
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scene/Ending Scene/to_be_continued.tscn")
	

func change_quest_title(new_title: String) -> void:
	quest_title_instance._update_quest_title(new_title, true)
		
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
