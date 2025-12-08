extends Node

#@export var puzzle_morse_path: NodePath
@export var success_label_path: NodePath

#var puzzle_morse
var success_label

func _ready():
	var puzzle = get_tree().get_first_node_in_group("puzzle_morse")
	if puzzle:
		puzzle.answer_correct.connect(on_puzzle_correct)
	#pass  

func on_puzzle_correct():
	print("Notif")
	$Objective/Title/Label.text = "Berikan kepada polisi"
	$Objective/AnimationPlayer.play("LabelStartAnimation")
	#$"UI/LabelSuccess".visible = true
	#$"UI/LabelSuccess".text = "Puzzle Selesai!"
	#$"UI/SuccessAnimation".play("fade_in")
