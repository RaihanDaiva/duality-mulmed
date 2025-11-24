# navigation_manager.gd
extends Node

const scene_kamar_dennis = preload("res://Map/Rumah Dennis/Kamar Dennis/kamar_dennis.tscn")
const scene_ruangan_tengah_dennis = preload("res://Map/Rumah Dennis/Ruang Tengah/ruangan_tengah_dennis.tscn")
const scene_toilet_dennis = preload("res://Map/Rumah Dennis/Toilet/toilet_dennis.tscn")
const scene_ruang_tv_dennis = preload("res://Map/Rumah Dennis/Ruang TV/ruang_tv_dennis.tscn")

signal on_trigger_player_spawn

var spawn_door_tag

func go_to_level(level_tag, destination_tag):
	var scene_to_load
	
	match level_tag:
		"kamar_dennis":
			scene_to_load = scene_kamar_dennis
		"ruangan_tengah_dennis":
			scene_to_load = scene_ruangan_tengah_dennis
		"toilet_dennis":
			scene_to_load = scene_toilet_dennis
		"ruang_tv_dennis":
			scene_to_load = scene_ruang_tv_dennis
	
	if scene_to_load != null:
		print("Changing to: ", level_tag)
		spawn_door_tag = destination_tag
		# GUNAKAN call_deferred untuk menunda hingga physics frame selesai
		get_tree().call_deferred("change_scene_to_packed", scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
