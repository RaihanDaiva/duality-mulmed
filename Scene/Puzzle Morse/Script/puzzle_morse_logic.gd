extends Node2D

# --- NODE PATHS (set di Inspector) ---
@export var answer_input_path: NodePath
@export var submit_button_path: NodePath
@export var hint_button_path: NodePath
@export var feedback_label_path: NodePath
@export var retry_button_path: NodePath
@export var game_over_panel_path: NodePath

# --- Puzzle configuration ---
@export var correct_answer = [
	["JAM", "JEM", "JOM"],   # Puzzle Answer for progress 1 and so on...
	["CI", "KO", "NENG"],
	["JAM", "JEM", "JOM"],
]
@export var hint_text: String = "Ada di dinding, menunjukkan waktu"
@export_file("*.tscn") var next_scene: String = ""  # Scene selanjutnya setelah berhasil

# --- Global game state
var puzzle_progress = 1	 # Start at one. It will progresses everytime this node is interacted

# --- Game state ---
var attempts: int = 0
var max_attempts: int = 3
var hint_used: bool = false
var puzzle_solved: bool = false
var level: int = 1

# --- Animation State ---
var isHidden: bool = false

# --- Node refs (diisi di _ready) ---
var answer_input: LineEdit = null
var submit_button: Button = null
var hint_button: Button = null
var feedback_label: Label = null
var retry_button: Button = null
var game_over_panel: Control = null

# --- Signals ---
signal puzzle_completed()
signal puzzle_failed()
signal answer_correct()
signal answer_wrong(remaining_attempts: int)

# ---------------------------
func _ready() -> void:
	print("atas ",correct_answer)
	await get_tree().process_frame
	# Resolve node references dari NodePath (jika diberikan)
	if answer_input_path and answer_input_path != NodePath(""):
		if has_node(answer_input_path):
			answer_input = get_node(answer_input_path)
	if submit_button_path and submit_button_path != NodePath(""):
		if has_node(submit_button_path):
			submit_button = get_node(submit_button_path)
	if hint_button_path and hint_button_path != NodePath(""):
		if has_node(hint_button_path):
			hint_button = get_node(hint_button_path)
	if feedback_label_path and feedback_label_path != NodePath(""):
		if has_node(feedback_label_path):
			feedback_label = get_node(feedback_label_path)
	if retry_button_path and retry_button_path != NodePath(""):
		if has_node(retry_button_path):
			retry_button = get_node(retry_button_path)
	if game_over_panel_path and game_over_panel_path != NodePath(""):
		if has_node(game_over_panel_path):
			game_over_panel = get_node(game_over_panel_path)

	# Lock player movement saat puzzle muncul
	var player = _get_player()
	if player:
		player.can_move = true
		player.direction = Vector2.ZERO
		
	
	var clues = correct_answer[puzzle_progress]
	#$"../Book Panel/FirstClue".text = "Clue #1: " + str(clues[0])
	#$"../Book Panel/SecondClue".text = "Clue #2: " + str(clues[1])
	#$"../Book Panel/ThirdClue".text = "Clue #3: " + str(clues[2])

	setup_connections()
	reset_puzzle()
	print("bawah ",correct_answer)

# ---------------------------
func setup_connections() -> void:
	if submit_button:
		# Connect safely menggunakan Callable
		if not submit_button.pressed.is_connected(Callable(self, "_on_submit_pressed")):
			submit_button.pressed.connect(Callable(self, "_on_submit_pressed"))
	if answer_input:
		# text_submitted signal
		if not answer_input.text_submitted.is_connected(Callable(self, "_on_answer_submitted")):
			answer_input.text_submitted.connect(Callable(self, "_on_answer_submitted"))
	if hint_button:
		if not hint_button.pressed.is_connected(Callable(self, "_on_hint_pressed")):
			hint_button.pressed.connect(Callable(self, "_on_hint_pressed"))
	if retry_button:
		if not retry_button.pressed.is_connected(Callable(self, "_on_retry_pressed")):
			retry_button.pressed.connect(Callable(self, "_on_retry_pressed"))

# ---------------------------
func reset_puzzle() -> void:
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
		# Beri fokus ke input agar pemain bisa mengetik jawaban
		answer_input.grab_focus()

# ---------------------------
func _on_submit_pressed() -> void:
	print("tes")
	check_answer()

func _on_answer_submitted(text: String) -> void:
	check_answer()

# ---------------------------
func check_answer() -> void:
	if puzzle_solved:
		return

	if not answer_input:
		show_feedback("Tidak ada input jawaban terpasang!")
		return

	print("progress =", puzzle_progress)
	print("level =", level)
	print("correct_answer =", correct_answer)
	print("row =", correct_answer[puzzle_progress - 1])


	var player_answer = answer_input.text.strip_edges().to_upper()
	var correct = correct_answer[puzzle_progress-1][level-1].strip_edges().to_upper()
	print("PLAYER'S ANSWER: ", player_answer)
	print("CORRECT ANSWER: ", correct)

	if player_answer.is_empty():
		show_feedback("Masukkan jawaban terlebih dahulu!")
		return

	attempts += 1

	if player_answer == correct:
		print("PLAYER INPUT: CORRECT")
		on_correct_answer()
	else:
		on_wrong_answer()

# ---------------------------
func on_correct_answer() -> void:
	State.current_subscene = "scene3"
	var puzzle_scene = get_parent()
	State.puzzle_scene_2 = "done"

	show_feedback("BENAR!")

	# tunggu sedikit lalu sembunyikan container puzzle (ini Control jadi aman)
	if State.give_puzzle_to_police_scene_3 == "true":
		$"../Objective/AnimationPlayer".play("LabelEndAnimation")
		await get_tree().create_timer(1.0).timeout
		puzzle_scene.visible = false

	# Disable input UI
	#if answer_input:
		#answer_input.editable = false
	#if submit_button:
		#submit_button.disabled = true
	#if hint_button:
		#hint_button.disabled = true

	# Emit signals yang benar
	emit_signal("answer_correct")
	emit_signal("puzzle_completed")
	
	match level:
		1:
			print("Clue 1 DONE")
			$"../Book Panel/FirstClueSprite/FirstClue".visible = true
			level += 1
			var move_answer_panel_delta = Vector2(0, 35) # Move the HAnswerContainer + 0 in x and +15 in y
			move_answer_panel(move_answer_panel_delta)
			_on_hide_show_book_pressed()
			answer_input.text = ""
			$"../Book Panel/FirstClueSprite/Null".visible = false
			$"../Book Panel/FirstClueSprite/True".visible = true
		2:
			print("Clue 2 DONE")
			$"../Book Panel/SecondClueSprite/SecondClue".visible = true
			level += 1
			var move_answer_panel_delta = Vector2(0, 35) # Move the HAnswerContainer + 0 in x and +15 in y
			move_answer_panel(move_answer_panel_delta)
			answer_input.text = ""
			$"../Book Panel/SecondClueSprite/Null".visible = false
			$"../Book Panel/SecondClueSprite/True".visible = true
		3:
			print("Clue 3 DONE")
			$"../Book Panel/ThirdClueSprite/ThirdClue".visible = true
			$"../Book Panel/HAnswerContainer".visible = false
			answer_input.text = ""
			$"../Book Panel/ThirdClueSprite/Null".visible = false
			$"../Book Panel/ThirdClueSprite/True".visible = true
			
			await get_tree().create_timer(1).timeout
			
			# Jika ada node StartAnimation di parent (konvensi sebelumnya), coba mainkan
			puzzle_solved = true
			if get_parent() and get_parent().has_node("StartAnimation"):
				get_parent().get_node("StartAnimation").play("puzzleEndAnimate")
			
			# Kembalikan kontrol ke player
			var player = _get_player()
			if player:
				player.can_move = true

			# visual akhir / animasi -> tunggu lalu play end animation jika ada
			await get_tree().create_timer(2).timeout
			$"../Objective".visible = true
			$"../Objective/Title/Label".text = "Berikan kepada polisi"
			$"../Objective/AnimationPlayer".play("LabelStartAnimation")
			await get_tree().create_timer(5).timeout
			$"../Objective/AnimationPlayer".play("LabelEndAnimation")
			await get_tree().create_timer(1).timeout
			$"..".visible = false
			
			await get_tree().create_timer(2.0).timeout
			go_to_next_scene()
		_:
			pass
	# Pindah ke scene berikutnya setelah delay (opsional)
	#if next_scene != "":
		#await get_tree().create_timer(2.0).timeout
		#go_to_next_scene()

# ---------------------------
func on_wrong_answer() -> void:
	var remaining = max_attempts - attempts
	#$"../UIAnimations".play("wrong_answer")
	#await $"../UIAnimations".animation_finished
	
	var tween = create_tween()
	var tween_alpha = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	$"../Book Panel/HAnswerContainer/Submit Btn/Wrong".visible = true
	tween.tween_property($"../Book Panel/HAnswerContainer/Submit Btn/Wrong", "position", Vector2(8,11), 0.1)
	tween.tween_property($"../Book Panel/HAnswerContainer/Submit Btn/Wrong", "position", Vector2(2,11), 0.1)
	tween.tween_property($"../Book Panel/HAnswerContainer/Submit Btn/Wrong", "position", Vector2(6,11), 0.1)
	tween.tween_property($"../Book Panel/HAnswerContainer/Submit Btn/Wrong", "position", Vector2(4,11), 0.1)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($"../Book Panel/HAnswerContainer/Submit Btn/Wrong", "position", Vector2(5,11), 0.25)
	
	tween_alpha.tween_property($"../Book Panel/HAnswerContainer/Submit Btn/Wrong", "modulate:a", 1, 0.1)
	tween_alpha.tween_interval(0.3)
	tween_alpha.tween_property($"../Book Panel/HAnswerContainer/Submit Btn/Wrong", "modulate:a", 0, 0.5)
	

	if remaining > 0:
		show_feedback("SALAH! Tersisa %d kesempatan." % remaining)

		if answer_input:
			answer_input.text = ""
			answer_input.grab_focus()

		emit_signal("answer_wrong", remaining)
	else:
		on_game_over()

# ---------------------------
func on_game_over() -> void:
	puzzle_solved = true

	show_feedback("GAME OVER!")

	# Disable input
	if answer_input:
		answer_input.editable = false
	if submit_button:
		submit_button.disabled = true
	if hint_button:
		hint_button.disabled = true

	# Show game over panel dengan retry
	if game_over_panel:
		game_over_panel.visible = true

	# Pastikan player bisa bergerak lagi setelah game over
	var player = _get_player()
	if player:
		player.can_move = true

	emit_signal("puzzle_failed")

# ---------------------------
func _on_hint_pressed() -> void:
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

# ---------------------------
func _on_retry_pressed() -> void:
	# Reset dan lock kembali player (karena puzzle muncul ulang)
	reset_puzzle()
	var player = _get_player()
	if player:
		player.can_move = false
		player.direction = Vector2.ZERO

# ---------------------------
func show_feedback(message: String) -> void:
	if feedback_label:
		feedback_label.text = message

# ---------------------------
func go_to_next_scene() -> void:
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		print("No next scene specified!")

# ---------------------------
# Helper: cari node player dari group "player"
func _get_player():
	var p = get_tree().get_first_node_in_group("player")
	return p

# ---------------------------
# Public helper methods
func set_answer(answer: String) -> void:
	correct_answer[0] = answer

func set_hint(hint: String) -> void:
	hint_text = hint

func set_next_scene(scene_path: String) -> void:
	next_scene = scene_path

func get_attempts() -> int:
	return attempts

func get_remaining_attempts() -> int:
	return max_attempts - attempts

func is_puzzle_solved() -> bool:
	return puzzle_solved

func _on_hide_show_book_pressed() -> void:
	if isHidden:
		isHidden = false
		if get_parent() and get_parent().has_node("ShowBookAnimation"):
			get_parent().get_node("ShowBookAnimation").play("hide_book_animation")
	else:
		isHidden = true
		if get_parent() and get_parent().has_node("ShowBookAnimation"):
			get_parent().get_node("ShowBookAnimation").play("show_book_animation")

func move_answer_panel(delta: Vector2) -> void:
	var anim_player: AnimationPlayer = $"../MoveAnswerPanelAnim"
	var anim: Animation = anim_player.get_animation("move_answer_container")

	# Debug prints
	print("Number of Keyframes: ", anim.track_get_key_count(0))

	# Get the 2nd keyframe (index 1)
	var pos_value: Vector2 = anim.track_get_key_value(0, 1)
	print("Before changing the position value: ", pos_value)

	# Apply delta
	pos_value += delta

	# Write new keyframe value
	anim.track_set_key_value(0, 1, pos_value)
	print("After changing the position value: ", pos_value)

	# Play animation
	anim_player.play("move_answer_container")
	await anim_player.animation_finished
	
	# Set 1st keyframe after moving
	anim.track_set_key_value(0, 0, pos_value)


func _on_hide_show_book_mouse_entered() -> void:
	$"../UIAnimations".play("hide_book_btn_hover_in")


func _on_hide_show_book_mouse_exited() -> void:
	$"../UIAnimations".play("hide_book_btn_hover_out")


func _on_submit_btn_mouse_entered() -> void:
	$"../UIAnimations".play("submit_hover_in")


func _on_submit_btn_mouse_exited() -> void:
	$"../UIAnimations".play("submit_hover_out")
