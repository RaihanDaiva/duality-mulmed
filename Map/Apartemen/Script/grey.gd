extends CharacterBody2D

@export var speed: float = 100.0
@export var move_direction: Vector2 = Vector2.UP
@export var destroy_on_hit: bool = true

var active := true
var state := "idle"
var cardinal_direction: Vector2 = Vector2.DOWN

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	move_direction = move_direction.normalized()
	update_direction_from_move()
	update_animation()


func _physics_process(delta):
	if not active:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = move_direction * speed
	move_and_slide()

	update_state()
	update_direction_from_move()
	update_animation()


# -----------------------------
# LOGIC ANIMASI (SAMA DENGAN PLAYER)
# -----------------------------

func update_state():
	state = "walk" if velocity != Vector2.ZERO else "idle"


func update_direction_from_move():
	if velocity == Vector2.ZERO:
		return

	if abs(velocity.x) > abs(velocity.y):
		cardinal_direction = Vector2.RIGHT if velocity.x > 0 else Vector2.LEFT
		sprite.scale.x = -1 if cardinal_direction == Vector2.LEFT else 1
	else:
		cardinal_direction = Vector2.DOWN if velocity.y > 0 else Vector2.UP


func update_animation():
	var anim_name = state + "_" + anim_direction()
	if animation_player.has_animation(anim_name):
		if animation_player.current_animation != anim_name:
			animation_player.play(anim_name)


func anim_direction() -> String:
	if cardinal_direction == Vector2.UP:
		return "up"
	elif cardinal_direction == Vector2.DOWN:
		return "down"
	else:
		return "side"


# -----------------------------
# COLLISION HIT
# -----------------------------

func on_hit():
	active = false
	velocity = Vector2.ZERO

	if destroy_on_hit:
		queue_free()
	else:
		hide()
