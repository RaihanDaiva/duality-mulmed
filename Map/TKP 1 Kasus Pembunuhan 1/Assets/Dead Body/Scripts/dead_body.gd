extends StaticBody2D

@export var npc_name: String = "NPC"
@export var can_interact: bool = true
@export_enum("down", "up", "side_left", "side_right") var idle_direction: String = "down"
@export_file("*.dialogue") var dialogue_file: String = "res://Map/TKP 1 Kasus Pembunuhan 1/Assets/Dialogue/dead_body.dialogue"
@export var dialogue_start: String = "start"
@export var change_scene_after_dialogue: bool = false
@export_file("*.tscn") var next_scene: String = ""
@export_file("*.tscn") var next_puzzle: String = ""

@onready var interaction_area = $InteractionArea if has_node("InteractionArea") else null
@onready var sprite = $Sprite2D
@onready var fade_transition = $"Fade Transition" if has_node("Fade Transition") else null

var dialogue_active: bool = false
signal dialogue_finished

func _ready():
	emit_signal("dialogue_finished")
	# Setup interaction 	
	if interaction_area and can_interact:
		interaction_area.interact = Callable(self, "_talk")
	elif interaction_area and not can_interact:
		interaction_area.monitoring = false
		interaction_area.visible = false
	
	if fade_transition:
		fade_transition.hide()
	


func _talk():
	if not can_interact:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	player.can_move = false
	player.direction = Vector2.ZERO
	dialogue_active = true
	
	print("Dialog dimulai dengan: ", npc_name)
	
	# Connect dengan CONNECT_ONE_SHOT agar auto-disconnect setelah dipanggil
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
	
	DialogueManager.show_dialogue_balloon(
		load(dialogue_file),
		dialogue_start
	)

func _on_dialogue_finished(resource):
	print("Dialog selesai dengan: ", npc_name)
	var player = get_tree().get_first_node_in_group("player")
	if player:
		dialogue_active = false
		player.can_move = true
	
	$InteractionArea/CollisionShape2D.disabled = true
	$"../../Objective/AnimationPlayer".play("LabelEndAnimation")
	
	if change_scene_after_dialogue and next_scene != "":
		change_to_scene()
	
	show_next_puzzle()
		
func show_next_puzzle():
	if next_puzzle == "":
		print("next_puzzle belum dipilih di Inspector!")
		return
	print("puzzle morse")
	# Load scene
	var scene_res = load(next_puzzle)
	var puzzle_scene = scene_res.instantiate()

	# Tambahkan ke parent (atau node lain sesuai kebutuhan)
	get_parent().add_child(puzzle_scene)
	
	# Ubah Quest Title
	if State.current_subscene == "scene2":
		var parent = get_parent().get_parent()
		parent.change_quest_title("Berikan ke polisi")

	# Aktifkan (visible)
	puzzle_scene.visible = true

	# Mainkan animasinya
	# Pastikan node StartAnimation ada di dalam puzzle .tscn
	puzzle_scene.get_node("CanvasLayer/StartAnimation").play("puzzleStartAnimate")

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
