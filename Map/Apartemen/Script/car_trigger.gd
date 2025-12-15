extends Area2D

@export var destroy_body := true
var next_scene = "res://Map/Rumah Dennis/Halaman Luar/halaman_rumah_dennis.tscn"

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node):
	print("area")
	# Grey / Car / NPC
	if body.has_method("on_hit"):
		print("Body masuk trigger:", body.name)
		body.on_hit()
		await get_tree().create_timer(0.3).timeout
		_talk()
	
func _talk():
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		
	await get_tree().create_timer(1).timeout
	DialogueManager.show_dialogue_balloon(
		load("res://Scene/Scene 15 Part 2/Dialogue/grey.dialogue"),
		"start"
	)
	
func _on_grey_entered(body: Node):
	print("apart")
	_talk()
	# Grey / Car / NPC
	if body.has_method("on_hit"):
		print("Body masuk trigger:", body.name)
		body.on_hit()
		
func change_to_scene():
	#if fade_transition:
		#fade_transition.show()
		#var fade_anim = fade_transition.get_node("AnimationPlayer")
		
		#if fade_anim:
			#fade_anim.play("fade_in")
			#await fade_anim.animation_finished

	get_tree().change_scene_to_file(next_scene)
	
func _on_dialogue_finished(resource):
	State.current_subscene = "scene16"
	change_to_scene()
