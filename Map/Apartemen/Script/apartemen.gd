extends Node2D
var dialogue_active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.playing  = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_hit_area_area_entered(area: Area2D) -> void:
	pass # Replace with function body.
