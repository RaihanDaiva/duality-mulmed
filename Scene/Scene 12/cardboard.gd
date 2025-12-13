extends CharacterBody2D
class_name PushBox

@export var move_speed := 60.0

var push_direction: Vector2 = Vector2.ZERO

func _physics_process(delta):
	if push_direction == Vector2.ZERO:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	velocity = push_direction * move_speed
	move_and_slide()

	# ===== CEK COLLISION UNTUK PUSH BOX LAIN =====
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()

		if collider is PushBox:
			var other_box := collider as PushBox
			other_box.push_direction = push_direction

	# reset (harus di akhir!)
	push_direction = Vector2.ZERO
