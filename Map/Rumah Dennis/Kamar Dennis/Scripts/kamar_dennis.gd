extends Node2D

@onready var tilemap = $Environment/TileMap  # Path ke TileMap Anda
@onready var camera = $Player/Camera2D
var quest_title_instance

func update_interactables():
	#State untuk bed
	if State.current_subscene == "scene4":
		$Bed/InteractionArea/CollisionShape2D.disabled = false
		
#Untuk navigasi ruangan harus menambahkan ini
func _ready():
	#State.current_subscene = "scene17"
	State.current_room = "kamar"
	print(State.current_subscene)
	var quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
	quest_title_instance = quest_title.instantiate()
	add_child(quest_title_instance)
	
	if State.current_subscene == "scene4":
		State.quest_title = "ke kasur"
		State.current_room = "kamar"
		change_quest_title("Ke kasur")
	elif State.current_subscene == "scene6":
		if !State.wake_up:
			_talk()
		State.quest_car_done = "start"
		State.quest_title = "ke luar rumah"
		change_quest_title("Ke luar rumah")
	elif State.current_subscene == "scene17":
		change_quest_title("Cari Sesuatu")
		$Grey.visible = true
		$Grey/CollisionShape2D.disabled = false
		print("quest hole ",State.quest_hole)
		if !State.quest_hole:
			$Environment/Hole.visible = false
			$Environment/Hole/CollisionShape2D.disabled = true
			$Doors/Door_S/CollisionShape2D.disabled = true
			$"Environment/Hole Interaction/InteractionArea/CollisionShape2D".disabled = false
		else:
			$Environment/Hole.visible = true
			$Environment/Hole/CollisionShape2D.disabled = false
			$Doors/Door_S/CollisionShape2D.disabled = false
	elif State.current_subscene == "scene18" or "scene19":
		change_quest_title("Masuk ke bawah")
		$"Environment/Hole Interaction/InteractionArea/CollisionShape2D".disabled = true
		$Environment/Hole.visible = true
		$Environment/Hole/CollisionShape2D.disabled = false
		$Doors/Door_S/CollisionShape2D.disabled = false
		
	print(State.current_room)
	update_interactables()
	auto_setup_camera_from_tilemap()
	if State.quest_bed_done != "done":
		if NavigationManager.spawn_door_tag != null:
			_on_level_spawn(NavigationManager.spawn_door_tag)
	elif State.current_subscene == "scene6":
		if State.quest_bed:
			$"Fade Transition2".visible = true
			$"Fade Transition2/AnimationPlayer".play("fade_out")
	
	if State.scene12_give_evidence:
		$BlackOverlay.visible = true

func _talk():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = false
		player.direction = Vector2.ZERO
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		
	await get_tree().create_timer(1).timeout
	DialogueManager.show_dialogue_balloon(
		load("res://Scene/Scene 6/Dialogue/wake_up.dialogue"),
		"start"
	)
	
func _on_dialogue_finished(resource):
	State.wake_up = true
	if State.current_subscene == "scene6":
		change_quest_title("Ke luar rumah")
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true
		
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
