extends Node2D

@onready var tilemap = $Environment/TileMap  # Path ke TileMap Anda
@onready var camera = $Player/Camera2D
var quest_title_instance

#Untuk navigasi ruangan harus menambahkan ini
func _ready():
	State.quest_dead_body_done = true #nanti dihapus
	State.current_subscene = "scene10" #nanti dihapus
	print(State.current_subscene)
	var quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
	quest_title_instance = quest_title.instantiate()
	add_child(quest_title_instance)
	if State.current_subscene == "scene7":
		if State.quest_table_done != "start" and State.quest_table_done != "done":
			State.quest_table_done = "start"
		elif State.quest_table_done != "done":
				change_quest_title("Ke Ruangan Dennis")
	elif State.current_subscene == "scene9":
		State.current_subscene = "scene10"
	elif State.current_subscene == "scene10":
		change_quest_title("Ke Ruangan Dennis")
	
	auto_setup_camera_from_tilemap()
	if State.current_subscene == "scene7":
		if NavigationManager.spawn_door_tag != null:
			_on_level_spawn(NavigationManager.spawn_door_tag)
	else:
		pass
	
		
func change_quest_title(new_title: String) -> void:
	if State.current_subscene == "scene7":
		quest_title_instance._update_quest_title(new_title, true)
	elif State.current_subscene == "scene10": 
		quest_title_instance._update_quest_title(new_title, true)
				
func _on_level_spawn(destination_tag: String):
	var door_path = "Doors/Door_" + destination_tag
	var door = get_node(door_path) as Door
	NavigationManager.trigger_player_spawn(door.spawn.global_position, door.spawn_direction)
	#print("=========>>>>", door.spawn.global_position)
	
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
