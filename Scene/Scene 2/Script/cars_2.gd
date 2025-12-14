extends StaticBody2D

@export var npc_name: String = "NPC"
@export var can_interact: bool = true
@export var use_dialogue: bool = true   # ← CHECKBOX BARU

@export_enum("down", "up", "side_left", "side_right")
var idle_direction: String = "down"

@export_file("*.dialogue")
var dialogue_file: String = ""

@export var dialogue_start: String = "start"

@export var change_scene_after_dialogue: bool = false
@export_file("*.tscn") var next_scene: String = ""
@export_file("*.tscn") var next_puzzle: String = ""

@onready var interaction_area = $InteractionArea if has_node("InteractionArea") else null
@onready var sprite = $Sprite2D
@onready var fade_transition =  $"Fade Transition" if has_node("Fade Transition") else null

var dialogue_active: bool = false


func _ready():


	# Contoh kondisi disable interaction by state (punyamu)
	if State.current_subscene == "scene4":
		$InteractionArea/CollisionShape2D.disabled = true
	elif State.current_subscene == "scene6":
		$InteractionArea/CollisionShape2D.disabled = false
	elif State.current_subscene == "scene10":
		$".".visible = false
		$InteractionArea/CollisionShape2D.disabled = true
		#
		#$"../Cars3".visible = true
		#$"../Cars3/InteractionArea/CollisionShape2D".disabled = false
		
	# --- SETUP INTERACTION ---
	if interaction_area and can_interact:

		if use_dialogue:
			# Kalau pakai dialogue, pastikan file valid
			if dialogue_file != "":
				interaction_area.interact = Callable(self, "_talk")
			else:
				push_warning("use_dialogue = true, tapi dialogue_file kosong pada: " + name)
		else:
			# Kalau TIDAK pakai dialogue, tinggal hapus fungsi talk
			interaction_area.interact = func():
				if change_scene_after_dialogue and next_scene != "":
					change_to_scene()

	elif interaction_area and not can_interact:
		interaction_area.monitoring = false
		interaction_area.visible = false

	if fade_transition:
		fade_transition.hide()

func _talk():
	if not can_interact or not use_dialogue:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	player.can_move = false
	player.direction = Vector2.ZERO
	dialogue_active = true
	
	print("Dialog dimulai dengan:", npc_name)
	
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
	
	DialogueManager.show_dialogue_balloon(
		load(dialogue_file),
		dialogue_start
	)



func _on_dialogue_finished(resource):
	print("before",NavigationManager.spawn_door_tag)
	NavigationManager.spawn_door_tag = null
	print("after",NavigationManager.spawn_door_tag)
	# Contoh update state punyamu
	if State.current_subscene == "scene3":
		State.current_subscene = "scene4"
	elif State.current_subscene == "scene6":
		State.current_subscene = "scene7"
	elif State.current_subscene == "scene9":
		State.current_subscene = "scene10"
	elif State.current_subscene == "scene12":
		State.current_subscene = "scene13"
	
	print("Dialog selesai dengan:", npc_name)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		dialogue_active = false
		player.can_move = true
	
	$"../../Fade Transition2/AnimationPlayer".play("fade_in")
	
	await get_tree().create_timer(1.0).timeout

	if change_scene_after_dialogue and next_scene != "":
		change_to_scene()

	show_next_puzzle()



func show_next_puzzle():
	if next_puzzle == "":
		print("next_puzzle belum dipilih!")
		return
	
	var scene_res = load(next_puzzle)
	var puzzle_scene = scene_res.instantiate()

	get_parent().add_child(puzzle_scene)
	puzzle_scene.visible = true
	puzzle_scene.get_node("StartAnimation").play("puzzleStartAnimate")



func change_to_scene():
	if fade_transition:
		fade_transition.show()
		var fade_anim = fade_transition.get_node("AnimationPlayer")
		if fade_anim:
			fade_anim.play("fade_in")
			await fade_anim.animation_finished
		
		get_tree().change_scene_to_file(next_scene)
	else:
		get_tree().change_scene_to_file(next_scene)
