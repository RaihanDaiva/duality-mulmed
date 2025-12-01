# cutscene_controller.gd
extends Control

@onready var video_player = $VideoStreamPlayer

@export_file("*.ogg", "*.ogv") var video_path: String = ""
@export var skip_enabled: bool = true
@export_file("*.tscn") var next_scene: String = ""

func _ready():
	size = get_viewport_rect().size
	
	if video_path != "":
		load_and_play_video(video_path)
	
	video_player.finished.connect(_on_video_finished)

func load_and_play_video(path: String):
	if not FileAccess.file_exists(path):
		push_error("Video file not found: " + path)
		return
	
	# Buat VideoStreamTheora resource
	var video_stream = VideoStreamTheora.new()
	
	# Load file .ogg
	video_stream.file = path
	
	# Set ke player
	video_player.stream = video_stream
	
	# Scale to fit
	fit_video_to_screen()
	
	# Play
	video_player.play()
	
	print("Playing video: ", path)

func fit_video_to_screen():
	var viewport_size = get_viewport_rect().size
	
	# Set size to cover viewport
	video_player.size = viewport_size
	video_player.position = Vector2.ZERO
	
	# Use expand mode
	video_player.expand = true

func _input(event):
	if skip_enabled and event.is_action_pressed("ui_cancel"):
		skip_cutscene()

func skip_cutscene():
	video_player.stop()
	go_to_next_scene()

func _on_video_finished():
	go_to_next_scene()

func go_to_next_scene():
	if next_scene != "":
		get_tree().change_scene_to_file(next_scene)
	else:
		print("No next scene specified")
