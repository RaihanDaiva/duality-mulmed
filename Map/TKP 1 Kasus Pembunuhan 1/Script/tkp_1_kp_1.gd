extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Fade Transition/AnimationPlayer".play("fade_out")


func _on_timer_timeout() -> void:
	pass # Replace with function body.
