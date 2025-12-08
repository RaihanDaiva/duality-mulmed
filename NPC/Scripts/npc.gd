extends StaticBody2D

@export var npc_name: String = "NPC"
@export var can_interact: bool = true
@export_enum("none", "down", "up", "side_left", "side_right") var idle_direction: String = "down"
@export_file("*.dialogue") var dialogue_file: String = "res://Dialogue/Main.dialogue"
@export var dialogue_start: String = "start"
@export var change_scene_after_dialogue: bool = false
@export_file("*.tscn") var next_scene: String = ""

@onready var interaction_area = $InteractionArea if has_node("InteractionArea") else null
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var fade_transition = $"Fade Transition" if has_node("Fade Transition") else null

var dialogue_active: bool = false

func _ready():
	# Setup interaction
	if interaction_area and can_interact:
		interaction_area.interact = Callable(self, "_talk")
	elif interaction_area and not can_interact:
		interaction_area.monitoring = false
		interaction_area.visible = false
	
	if fade_transition:
		fade_transition.hide()
	
	play_idle_animation()

func play_idle_animation():
	if not animation_player:
		return
	
	match idle_direction:
		"none":
			pass
		"down":
			animation_player.play("idle_down")
		"up":
			animation_player.play("idle_up")
		"side_left":
			sprite.scale.x = -1
			animation_player.play("idle_side")
		"side_right":
			sprite.scale.x = 1
			animation_player.play("idle_side")

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
		
		if State.give_puzzle_to_police_scene_3 == "true":
			$"../../Objective/Title/Label".text = "Kembali ke mobil"
			$"../../Objective/AnimationPlayer".play("LabelStartAnimation")
			$"../Environment/Cars2/InteractionArea/CollisionShape2D".disabled = false
			$InteractionArea/CollisionShape2D.disabled = true
	if change_scene_after_dialogue and next_scene != "":
		change_to_scene()

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
