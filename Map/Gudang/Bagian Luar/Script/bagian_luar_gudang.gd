extends Node2D

@onready var tilemap = $Environment/TileMap  # Path ke TileMap Anda
@onready var camera = $Player/Camera2D

#Untuk navigasi ruangan harus menambahkan ini
func _ready():
	print(State.current_subscene)
	#State.current_subscene = "scene12"
	if State.current_subscene == "scene10":
		State.current_subscene = "scene11"
	
	if State.have_key:
		$Doors/Door_N/CollisionShape2D.disabled = false
		$Environment/Gate/InteractionArea/CollisionShape2D.disabled = true
		
		$Environment/Key.visible = false
		$Environment/Key/CollisionShape2D.disabled = true
		$Environment/Key/InteractionArea/CollisionShape2D.disabled = true
		
	else:
		$Doors/Door_N/CollisionShape2D.disabled = true
	auto_setup_camera_from_tilemap()
	if NavigationManager.spawn_door_tag != null:
		_on_level_spawn(NavigationManager.spawn_door_tag)
	
	State.setup_quest_title($".")
	if !State.have_feet:
		State.quest_title = "Cari Cara Masuk Gudang"
	State.set_quest_title($".", true)
		
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
