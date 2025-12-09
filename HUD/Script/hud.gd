extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func set_objective(text):
	var label = get_node_or_null("Objective/Title/Label")
	if label:
		label.text = text
	else:
		push_error("Label objective tidak ditemukan!")
