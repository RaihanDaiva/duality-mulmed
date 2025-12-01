extends Node

# Reference ke UI nodes (set di Inspector atau via code)
@export var answer_input: LineEdit
@export var submit_button: Button
@export var hint_button: Button
@export var feedback_label: Label
@export var retry_button: Button
@export var game_over_panel: Control

# Puzzle configuration
@export var correct_answer: String = "JAM"  # Jawaban yang benar
@export var hint_text: String = "Ada di dinding, menunjukkan waktu"
@export_file("*.tscn") var next_scene: String = ""  # Scene selanjutnya setelah berhasil

# Game state
var attempts: int = 0
var max_attempts: int = 3
var hint_used: bool = false
var puzzle_solved: bool = false

# Signals
signal puzzle_completed()
signal puzzle_failed()
signal answer_correct()
signal answer_wrong(remaining_attempts: int)

func _ready():
	setup_connections()
	reset_puzzle()

func setup_connections():
	if submit_button:
		submit_button.pressed.connect(_on_submit_pressed)
	
	if answer_input:
		answer_input.text_submitted.connect(_on_answer_submitted)
	
	if hint_button:
		hint_button.pressed.connect(_on_hint_pressed)
	
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)

func reset_puzzle():
	attempts = 0
	hint_used = false
	puzzle_solved = false
	
	if answer_input:
		answer_input.text = ""
		answer_input.editable = true
	
	if submit_button:
		submit_button.disabled = false
	
	if hint_button:
		hint_button.disabled = false
	
	if feedback_label:
		feedback_label.text = ""
	
	if game_over_panel:
		game_over_panel.visible = false
	
	if answer_input:
		answer_input.grab_focus()

func _on_submit_pressed():
	check_answer()

func _on_answer_submitted(text: String):
	check_answer()

func check_answer():
	if puzzle_solved:
		return
	
	if not answer_input:
		return
	
	var player_answer = answer_input.text.strip_edges().to_upper()
	var correct = correct_answer.strip_edges().to_upper()
	
	if player_answer.is_empty():
		show_feedback("Masukkan jawaban terlebih dahulu!")
		return
	
	attempts += 1
	
	if player_answer == correct:
		on_correct_answer()
	else:
		on_wrong_answer()

func on_correct_answer():
	puzzle_solved = true
	
	show_feedback("BENAR!")
	
	# Disable input
	if answer_input:
		answer_input.editable = false
	if submit_button:
		submit_button.disabled = true
	if hint_button:
		hint_button.disabled = true
	
	answer_correct.emit()
	puzzle_completed.emit()
	
	# Pindah ke scene berikutnya setelah delay
	if next_scene != "":
		await get_tree().create_timer(2.0).timeout
		go_to_next_scene()

func on_wrong_answer():
	var remaining = max_attempts - attempts
	
	if remaining > 0:
		show_feedback("SALAH! Tersisa %d kesempatan." % remaining)
		
		if answer_input:
			answer_input.text = ""
			answer_input.grab_focus()
		
		answer_wrong.emit(remaining)
	else:
		on_game_over()

func on_game_over():
	puzzle_solved = true
	
	show_feedback("GAME OVER!")
	
	# Disable input
	if answer_input:
		answer_input.editable = false
	if submit_button:
		submit_button.disabled = true
	if hint_button:
		hint_button.disabled = true
	
	# Show game over panel with retry button
	if game_over_panel:
		game_over_panel.visible = true
	
	puzzle_failed.emit()

func _on_hint_pressed():
	if hint_used:
		show_feedback("Petunjuk sudah digunakan!")
		return
	
	if hint_text.is_empty():
		show_feedback("Tidak ada petunjuk!")
		return
	
	show_feedback("Petunjuk: " + hint_text)
	hint_used = true
	
	if hint_button:
		hint_button.disabled = true

func _on_retry_pressed():
	reset_puzzle()

func show_feedback(message: String):
	if feedback_label:
		feedback_label.text = message

func go_to_next_scene():
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		print("No next scene specified!")

# Public methods untuk kontrol dari luar
func set_answer(answer: String):
	correct_answer = answer

func set_hint(hint: String):
	hint_text = hint

func set_next_scene(scene_path: String):
	next_scene = scene_path

func get_attempts() -> int:
	return attempts

func get_remaining_attempts() -> int:
	return max_attempts - attempts

func is_puzzle_solved() -> bool:
	return puzzle_solved
