extends Node

var button_type = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_pressed() -> void:
	#get_tree().change_scene_to_file("res://Map/TKP 1 Kasus Pembunuhan 1/tkp_1_kp_1.tscn")
	button_type = "start"
	$"Fade Transition".show()
	$"Fade Transition/Fade_timer".start()
	$"Fade Transition/AnimationPlayer".play("fade_in")


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	get_tree().quit()
	



func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://Scene/Scene 1/scene_1.tscn")
