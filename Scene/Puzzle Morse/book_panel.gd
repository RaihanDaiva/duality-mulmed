extends Panel

var puzzle_progress = PuzzleMorseLogic.puzzle_progress
var answers = PuzzleMorseLogic.correct_answer[puzzle_progress-1]

func _ready() -> void:
	$"../Book Panel/FirstClue".text = "Clue #1: " + str(answers[0])
	$"../Book Panel/SecondClue".text = "Clue #2: " + str(answers[1])
	$"../Book Panel/ThirdClue".text = "Clue #3: " + str(answers[2])
