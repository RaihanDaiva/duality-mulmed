extends Node

#const DOOR_OPEN_PATH  := "res://Car SFX Manager/open car door.wav"
#const DOOR_CLOSE_PATH := "res://Car SFX Manager/close car door.wav"
const DOOR_OPEN_PATH  := "res://SFX/car open.mp3"
const DOOR_CLOSE_PATH := "res://SFX/car close.mp3"
const RAIN_PATH := "res://SFX/SFX Heavy Rain and Thunder.mp3"


var audio: AudioStreamPlayer
var sfx_door_open: AudioStream
var sfx_door_close: AudioStream
var sfx_rain: AudioStream


func _ready():
	print("CarSFXManager READY")

	# Load audio langsung dari path
	sfx_door_open  = load(DOOR_OPEN_PATH)
	sfx_door_close = load(DOOR_CLOSE_PATH)
	sfx_rain = load(RAIN_PATH)

	# Validasi
	if not sfx_door_open:
		push_error("❌ Gagal load DOOR OPEN SFX")
	if not sfx_door_close:
		push_error("❌ Gagal load DOOR CLOSE SFX")

	audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.bus = "Master"   # atau "SFX" kalau sudah ada bus SFX


func play_open():
	print("PLAY OPEN")
	if not sfx_door_open:
		print("OPEN SFX NULL")
		return

	audio.stream = sfx_door_open
	audio.play()


func play_close():
	print("PLAY CLOSE")
	if not sfx_door_close:
		print("CLOSE SFX NULL")
		return

	audio.stream = sfx_door_close
	audio.play()

func play_rain():
	audio.stream = sfx_rain
	audio.play()

func play_open_close(delay := 0.5):
	play_open()
	await get_tree().create_timer(delay).timeout
	play_close()
