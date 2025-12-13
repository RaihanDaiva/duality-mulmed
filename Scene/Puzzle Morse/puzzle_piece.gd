extends Node2D

signal placed(index)

@export var snap_distance: float = 24.0
@export var target_position: Vector2 = Vector2.ZERO
@export var lock_rotation: bool = true
@export var index: int = -1

# Optional: whether the piece should animate when snapping
@export var animate_snap: bool = true
@export var snap_duration: float = 0.12

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D


var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO
var _original_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	if sprite_2d.texture != null:
		var sprite_size : Vector2 = sprite_2d.texture.get_size()
		collision_shape_2d.shape.extents = sprite_size / 2.0
	_original_position = global_position
	# Ensure Area2D input_event is connected to our handler (safe if user forgets)
	if has_node("Area2D"):
		$Area2D.connect("input_event", Callable(self, "_on_Area2D_input_event"))

func _on_Area2D_input_event(viewport, event, shape_idx) -> void:
	# Mouse button
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_start_drag(event.position)
			else:
				_end_drag()
	# Touch (mobile)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_start_drag(event.position)
		else:
			_end_drag()

func _start_drag(pointer_pos: Vector2) -> void:
	_dragging = true
	# Keep the relative offset so piece doesn't jump to the mouse origin
	_drag_offset = global_position - get_global_mouse_position()
	_original_position = global_position
	set_process(true)
	# bring to front visually
	z_index = 100
	# optional visual hint
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 1, 1, 0.9)

func _end_drag() -> void:
	_dragging = false
	set_process(false)
	# restore z
	z_index = 0
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 1, 1, 1)

	var distance_to_target = global_position.distance_to(target_position)
	# Snap check
	if distance_to_target <= snap_distance:
		# Snap (optionally animate)
		if animate_snap:
			var tween = create_tween()
			tween.tween_property(self, "global_position", target_position, snap_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			# also clear rotation if locked
			if lock_rotation:
				tween.tween_property(self, "rotation", 0.0, snap_duration)
			# after tween completes, emit signal and disable further input
			tween.connect("finished", Callable(self, "_on_snap_finished"))
		else:
			global_position = target_position
			if lock_rotation:
				rotation = 0
			_on_snap_finished()
	else:
		# Not close enough — return to original position (simple)
		# you can also animate back if desired
		global_position = _original_position

func _on_snap_finished() -> void:
	# mark as placed: disable further input to this piece
	if has_node("Area2D"):
		$Area2D.set_monitoring(false)
		$Area2D/CollisionShape2D.disabled = true
		print("Monitoring Disabled")
	# prevent further dragging
	_dragging = false
	# emit signal so parent can react (e.g., count pieces)
	emit_signal("placed", index)
	
func _on_tween_finished() -> void:
	# mark as placed: disable further input to this piece
	if has_node("Area2D"):
		$Area2D.set_monitoring(false)
		$Area2D/CollisionShape2D.disabled = true
		print("Monitoring Disabled")
	# prevent further dragging
	_dragging = false

func _process(delta: float) -> void:
	if _dragging:
		global_position = get_global_mouse_position() + _drag_offset

# --- NEW: Tween-move function (call from code to move a piece) ---
# target: global position to move to
# duration: tween duration in seconds
# finalize: if true, call _on_snap_finished() when done (disables input and emits placed)
func tween_move_to(target: Vector2, duration: float = 0.12, finalize: bool = false) -> void:
	# stop any dragging or processing
	_dragging = false
	set_process(false)

	# bring to front while tweening
	z_index = 100
	if has_node("Sprite2D"):
		$Sprite2D.modulate = Color(1, 1, 1, 0.9)

	# create tween and tween global_position (and rotation if locked)
	var tw = create_tween()
	
	# TWEEN: Move
	tw.tween_property(self, "global_position", target, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	if lock_rotation:
		tw.tween_property(self, "rotation", 0.0, duration)

	# connect finish handler depending on finalize flag
	if finalize:
		# this will disable further input and emit placed
		tw.connect("finished", Callable(self, "_on_snap_finished"))
	else:
		# just restore visuals after movement
		tw.connect("finished", Callable(self, "_on_tween_finished"))
