# navigation_manager.gd
extends Node

#Rumah Dennis
const scene_kamar_dennis = preload("res://Map/Rumah Dennis/Kamar Dennis/kamar_dennis.tscn")
const scene_ruangan_tengah_dennis = preload("res://Map/Rumah Dennis/Ruang Tengah/ruangan_tengah_dennis.tscn")
const scene_toilet_dennis = preload("res://Map/Rumah Dennis/Toilet/toilet_dennis.tscn")
const scene_ruang_tv_dennis = preload("res://Map/Rumah Dennis/Ruang TV/ruang_tv_dennis.tscn")
const scene_halaman_dennis = preload("res://Map/Rumah Dennis/Halaman Luar/halaman_rumah_dennis.tscn")

#Kantor Polisi
const scene_kantor_ruangan_dennis = preload("res://Map/Kantor Polisi/Kantor Ruangan Dennis/kantor_ruangan_dennis.tscn")
const scene_kantor_ruangan_lobby = preload("res://Map/Kantor Polisi/Kantor Lobby/kantor_ruangan_lobby.tscn")
const scene_kantor_ruangan_meeting = preload("res://Map/Kantor Polisi/Kantor Ruangan Rapat/kantor_ruangan_rapat.tscn")
const scene_kantor_ruangan_main_1 = preload("res://Map/Kantor Polisi/Kantor Main1/kantor_ruangan_main_1.tscn")
const scene_kantor_ruangan_main_2 = preload("res://Map/Kantor Polisi/Kantor Main2/kantor_ruangan_main_2.tscn")


#Rumah TKP 1 KP 2
const scene_ruang_tengah_tkp1_kp2 = preload("res://Map/TKP1 Kasus Pembunuhan 2/Ruang Tengah/ruang_tengah_tkp_1_kp_2.tscn")
const scene_dapur_tkp1_kp2 = preload("res://Map/TKP1 Kasus Pembunuhan 2/Dapur/dapur_tkp_1_kp_2.tscn")
const scene_gudang_tkp1_kp2 = preload("res://Map/TKP1 Kasus Pembunuhan 2/Gudang/gudang_tkp_1_kp_2.tscn")
const scene_toilet_tkp1_kp2 = preload("res://Map/TKP1 Kasus Pembunuhan 2/Toilet/toilet_tkp_1_kp_2.tscn")
const scene_kamar_tkp1_kp2 = preload("res://Map/TKP1 Kasus Pembunuhan 2/Kamar/kamar_tkp_1_kp_2.tscn")
const scene_halaman_tkp1_kp2 = preload("res://Map/TKP1 Kasus Pembunuhan 2/Halaman/halaman_tkp_1_kp_2.tscn")

#Ruangan Rahasia Dennis
const scene_ruangan_rahasia_main_dennis = preload("res://Map/Rumah Dennis/Ruangan Rahasia/Main Room/ruang_rahasia_dennis_main.tscn")
const scene_ruangan_rahasia_operating_dennis = preload("res://Map/Rumah Dennis/Ruangan Rahasia/Operating Room/ruang_rahasia_dennis_operating.tscn")

#Gudang Bagian
const scene_bagian_dalam_gudang = preload("res://Map/Gudang/Bagian Dalam/bagian_dalam_gudang.tscn")
const scene_bagian_luar_gudang = preload("res://Map/Gudang/Bagian Luar/bagian_luar_gudang.tscn")

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
		"halaman_rumah_dennis":
			scene_to_load = scene_halaman_dennis
		"ruangan_rahasia_main_dennis":
			scene_to_load = scene_ruangan_rahasia_main_dennis
		"ruangan_rahasia_operating_dennis":
			scene_to_load = scene_ruangan_rahasia_operating_dennis
		"ruang_tengah_tkp1_kp2":
			scene_to_load = scene_ruang_tengah_tkp1_kp2
		"dapur_tkp1_kp2":
			scene_to_load = scene_dapur_tkp1_kp2
		"gudang_tkp1_kp2":
			scene_to_load = scene_gudang_tkp1_kp2
		"toilet_tkp1_kp2":
			scene_to_load = scene_toilet_tkp1_kp2
		"kamar_tkp1_kp2":
			scene_to_load = scene_kamar_tkp1_kp2
		"halaman_tkp1_kp2":
			scene_to_load = scene_halaman_tkp1_kp2
		"kantor_ruangan_dennis":
			scene_to_load = scene_kantor_ruangan_dennis
		"kantor_ruangan_lobby":
			scene_to_load = scene_kantor_ruangan_lobby
		"kantor_ruangan_meeting":
			scene_to_load = scene_kantor_ruangan_meeting
		"kantor_ruangan_main_1":
			scene_to_load = scene_kantor_ruangan_main_1
		"kantor_ruangan_main_2":
			scene_to_load = scene_kantor_ruangan_main_2
		"gudang_bagian_dalam":
			scene_to_load = scene_bagian_dalam_gudang
		"gudang_bagian_luar":
			scene_to_load = scene_bagian_luar_gudang
			
	if scene_to_load != null:
		print("Changing to: ", level_tag)
		spawn_door_tag = destination_tag
		# GUNAKAN call_deferred untuk menunda hingga physics frame selesai
		get_tree().call_deferred("change_scene_to_packed", scene_to_load)

func trigger_player_spawn(position: Vector2, direction: String):
	on_trigger_player_spawn.emit(position, direction)
