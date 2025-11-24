# scene_manager.gd
extends Node

var current_scene: Node = null
var player_spawn_position: Vector2 = Vector2.ZERO
var spawn_point_name: String = ""

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func change_scene(scene_path: String, spawn_point: String = ""):
	spawn_point_name = spawn_point
	
	call_deferred("_deferred_change_scene", scene_path)

func _deferred_change_scene(scene_path: String):
	if current_scene:
		current_scene.free()
	
	var new_scene = load(scene_path).instantiate()
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
	current_scene = new_scene
	
	# Cari player dan spawn point
	await get_tree().process_frame
	position_player()

func position_player():
	var player = get_tree().get_first_node_in_group("player")
	
	if not player:
		return
	
	# Cari spawn point dengan nama tertentu
	if spawn_point_name != "":
		var spawn_point = get_tree().get_first_node_in_group("spawn_points").get_node_or_null(spawn_point_name)
		if spawn_point:
			player.global_position = spawn_point.global_position
			print("Player spawned at: ", spawn_point_name)
		else:
			print("Spawn point not found: ", spawn_point_name)
	
	spawn_point_name = ""  # Reset
