extends CharacterBody2D
class_name Player 

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var move_speed: float = 80 
var state : String = "idle"
var can_move: bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var footstep_audio: AudioStreamPlayer = $FootstepAudio

# Footstep configuration
@export var footstep_sounds: Array[AudioStream] = []

# Track which frame played sound
var last_footstep_frame: int = -1

func _ready() -> void:
	add_to_group("player")
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	
	if footstep_sounds.is_empty():
		load_default_footsteps()
	
	# Connect ke animation player
	animation_player.animation_finished.connect(_on_animation_finished)

func load_default_footsteps():
	var footstep_paths = [
		"res://SFX/walking sound effect.wav",
		"res://SFX/walking sound effect2.wav",
		"res://SFX/walking sound effect3.wav",
		"res://SFX/walking sound effect4.wav",
		
	]
	
	for path in footstep_paths:
		if FileAccess.file_exists(path):
			footstep_sounds.append(load(path))

func _on_spawn(position: Vector2, direction: String):
	global_position = position
	
	match direction:
		"up":
			cardinal_direction = Vector2.UP
		"down":
			cardinal_direction = Vector2.DOWN
		"left":
			cardinal_direction = Vector2.LEFT
			sprite_2d.scale.x = -1
		"right":
			cardinal_direction = Vector2.RIGHT
			sprite_2d.scale.x = 1
	
	state = "idle"
	
	var anim_name = "idle_" + AnimDirection()
	if animation_player.has_animation(anim_name):
		animation_player.play(anim_name)
	
	print("Player spawned at: ", position, " facing: ", direction)

func _process(delta: float) -> void:
	if !can_move:
		direction = Vector2.ZERO
		if setState() == true || SetDirection() == true:
			UpdateAnimation()
		return
	
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	
	# Check footstep pada frame tertentu
	if state == "walk":
		check_footstep_frame()
	
	if setState() == true || SetDirection() == true:
		UpdateAnimation()

func check_footstep_frame():
	# Get current animation info
	var current_anim = animation_player.current_animation
	if not current_anim.begins_with("walk"):
		return
	
	# Get animation time
	var anim_position = animation_player.current_animation_position
	var anim_length = animation_player.current_animation_length  # 0.8 detik
	
	# Calculate current frame (4 frames total)
	var frame = int((anim_position / anim_length) * 4)
	
	# Play sound pada frame 0 dan 2 (saat kaki menyentuh tanah)
	if (frame == 0 or frame == 2) and frame != last_footstep_frame:
		play_footstep_sound()
		last_footstep_frame = frame

func _on_animation_finished(anim_name: String):
	# Reset frame tracker saat animasi selesai
	last_footstep_frame = -1

func _physics_process(delta: float) -> void:
	if !can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = direction.normalized() * move_speed
	move_and_slide()

func play_footstep_sound():
	if footstep_sounds.is_empty() or not footstep_audio:
		return
	
	# Random footstep untuk variasi
	var random_sound = footstep_sounds[randi() % footstep_sounds.size()]
	footstep_audio.stream = random_sound
	
	# Randomize pitch sedikit untuk variasi natural
	footstep_audio.pitch_scale = randf_range(0.9, 1.1)
	
	footstep_audio.play()

func SetDirection() -> bool:
	var new_dir : Vector2 = cardinal_direction
	if direction == Vector2.ZERO:
		return false
	
	if direction.y == 0:
		new_dir = Vector2.LEFT if direction.x < 0 else Vector2.RIGHT
	elif direction.x == 0:
		new_dir = Vector2.UP if direction.y < 0 else Vector2.DOWN
	
	if new_dir == cardinal_direction:
		return false
	
	cardinal_direction = new_dir
	sprite_2d.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	return true

func setState() -> bool:
	var new_state : String = "idle" if direction == Vector2.ZERO else "walk"
	if new_state == state:
		return false
	state = new_state
	return true

func UpdateAnimation() -> void:
	animation_player.play(state + "_" + AnimDirection())

func AnimDirection() -> String:
	if cardinal_direction == Vector2.DOWN:
		return "down"
	elif cardinal_direction == Vector2.UP:
		return "up"
	else:
		return "side"
