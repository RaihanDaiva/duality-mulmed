extends Node2D

@onready var tilemap = $Environment/TileMap  # Path ke TileMap Anda
@onready var camera = $Player/Camera2D
var quest_title_instance

#Untuk navigasi ruangan harus menambahkan ini
func _ready():
	State.quest_bed_done = "start"
	#State.current_subscene = "scene6" #akan dihapus
	print(State.current_subscene)
	var quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
	quest_title_instance = quest_title.instantiate()
	add_child(quest_title_instance)
	
	#Objective
	if State.current_subscene == "scene4":
		change_quest_title("Masuk Ke Rumah")
	elif State.current_subscene == "scene6":
		change_quest_title("Masuk ke mobil")
	elif State.current_subscene == "scene16":
		change_quest_title("Masuk ke rumah")
		if !State.entered_house:
			NavigationManager.spawn_door_tag = null
	var anim = get_node_or_null("Fade Transition2/AnimationPlayer")
	if anim:
		# Node ditemukan → aman digunakan
		$"Fade Transition2/AnimationPlayer".play("fade_out")
	else:
		# Node tidak ditemukan → skip tanpa error
		print("AnimationPlayer tidak ada, skip.")
	auto_setup_camera_from_tilemap()
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)
		
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
