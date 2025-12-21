extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"CanvasLayer/Fade Transition2".visible = true
	$"CanvasLayer/Fade Transition2/AnimationPlayer".play("fade_out")
	
	await get_tree().create_timer(2).timeout
	
	$"CanvasLayer/Fade Transition2".visible = true
	$"CanvasLayer/Fade Transition2/AnimationPlayer".play("fade_in")
	
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://UI/MainMenu/MainMenu.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
