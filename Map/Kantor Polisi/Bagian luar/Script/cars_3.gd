extends StaticBody2D

@export var npc_name := "Car"
@export var can_interact := true
@export var use_dialogue := true

@export_file("*.dialogue")
var dialogue_file := ""

@export var dialogue_start := "start"

# KEY = State.current_subscene
# VALUE = scene tujuan
@export var next_scenes := {
	"scene8": "res://Map/TKP1 Kasus Pembunuhan 2/Halaman/halaman_tkp_1_kp_2.tscn",
	"scene10": "res://Map/Gudang/Bagian Luar/bagian_luar_gudang.tscn",
	"scene15": "res://Map/Apartemen/apartemen.tscn"
}

@onready var interaction_area: Area2D = $InteractionArea
@onready var fade_transition = $"Fade Transition" if has_node("Fade Transition") else null

var dialogue_active := false


func _ready():
	if not interaction_area:
		return

	if can_interact:
		interaction_area.interact = Callable(self, "_on_interact")
	else:
		interaction_area.monitoring = false
		interaction_area.visible = false

	if fade_transition:
		fade_transition.hide()


func _on_interact():
	$"../../Player".visible = false
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	# 🔒 LOCK PLAYER
	player.can_move = false
	player.direction = Vector2.ZERO
	dialogue_active = true

	DialogueManager.dialogue_ended.connect(
		_on_dialogue_finished,
		CONNECT_ONE_SHOT
	)

	# KHUSUS SCENE 15 → dialog grey
	if State.current_subscene == "scene15":
		DialogueManager.show_dialogue_balloon(
			load("res://Scene/Scene 15 Part 1/Dialogue/grey.dialogue"),
			"start"
		)
		return

	# SCENE LAIN
	if use_dialogue:
		DialogueManager.show_dialogue_balloon(
			load(dialogue_file),
			dialogue_start
		)
	else:
		_try_change_scene()


func _on_dialogue_finished(_resource):
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.can_move = true   # 🔓 UNLOCK PLAYER

	dialogue_active = false

	_try_change_scene()


func _try_change_scene():
	var scene_path := get_next_scene_from_state()
	if scene_path == "":
		print("Tidak ada scene tujuan untuk:", State.current_subscene)
		return

	await _play_fade()
	get_tree().change_scene_to_file(scene_path)


func get_next_scene_from_state() -> String:
	if next_scenes.has(State.current_subscene):
		return next_scenes[State.current_subscene]
	return ""


func _play_fade():
	if not fade_transition:
		return

	fade_transition.show()
	var anim = fade_transition.get_node("AnimationPlayer")
	if anim:
		anim.play("fade_in")
		await anim.animation_finished
