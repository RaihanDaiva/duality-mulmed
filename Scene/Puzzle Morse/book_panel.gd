extends Panel

var puzzle_progress
var answers

func _ready() -> void:
	if State.current_subscene == "scene2":
		puzzle_progress = 1
		answers = PuzzleMorseLogic.correct_answer[puzzle_progress-1]
	elif State.current_subscene == "scene10":
		puzzle_progress = 2
		answers = PuzzleMorseLogic.correct_answer[puzzle_progress-1]
	elif State.current_subscene == "scene14":
		puzzle_progress = 3
		answers = PuzzleMorseLogic.correct_answer[puzzle_progress-1]
	print("==============>", puzzle_progress)
	$FirstClueSprite/FirstClue.text = str(answers[0])
	$SecondClueSprite/SecondClue.text = str(answers[1])
	$ThirdClueSprite/ThirdClue.text = str(answers[2])
