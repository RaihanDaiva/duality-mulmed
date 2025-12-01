extends CharacterBody2D

class_name Player 

var cardinal_direction : Vector2 = Vector2.DOWN
var direction : Vector2 = Vector2.ZERO
var move_speed: float = 80 
var state : String = "idle"
var can_move: bool = true

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("player")  # Penting untuk referensi
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	
func _on_spawn(position: Vector2, direction: String):
	global_position = position
	
	# Update cardinal_direction berdasarkan spawn direction
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
	
	# Set state ke idle
	state = "idle"
	
	# Play animation yang benar
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
	
	if setState() == true || SetDirection() == true:
		UpdateAnimation()

func _physics_process(delta: float) -> void:
	if !can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	direction.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	direction.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	velocity = direction.normalized() * move_speed
	move_and_slide()

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
