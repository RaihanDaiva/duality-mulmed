extends Node2D

@export var objective_text := "Pergi ke kamar"

func _ready():
	Hud.set_objective(objective_text)
	print(get_tree().current_scene.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
