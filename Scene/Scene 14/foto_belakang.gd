extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_talk()

func _talk():
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		
	await get_tree().create_timer(1).timeout
	DialogueManager.show_dialogue_balloon(
		load("res://Scene/Scene 14/foto_belakang.dialogue"),
		"start"
	)
	
func _on_dialogue_finished(resource):
	get_tree().change_scene_to_file("res://Map/Kantor Polisi/Kantor Ruangan Dennis/kantor_ruangan_dennis.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
