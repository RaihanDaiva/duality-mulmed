extends Panel

var puzzle_progress = PuzzleMorseLogic.puzzle_progress
var answers = PuzzleMorseLogic.correct_answer[puzzle_progress-1]

func _ready() -> void:
	$FirstClueSprite/FirstClue.text = str(answers[0])
	$SecondClueSprite/SecondClue.text = str(answers[1])
	$ThirdClueSprite/ThirdClue.text = str(answers[2])
