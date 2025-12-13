extends Node2D

var finished_pieces: Array[int]

@export var answer: Sprite2D
@export var jigsaw_holder: Texture
@export var jigsaw_pieces: Array[Node2D]

@onready var container: Node2D = $Container
@onready var jigsaw_holder_sprite: Sprite2D = $Container/JigsawHolder

@export var piece_spacing: Vector2 = Vector2(128, 128)
@export var start_offset: Vector2 = Vector2(0, 0)

signal puzzle_finished

func _ready() -> void:
	# make sure the holder sprite has its texture
	jigsaw_holder_sprite.texture = jigsaw_holder

	var n = jigsaw_pieces.size()
	if n == 0:
		print("No jigsaw pieces to assign.")
		return

	# Get container (where pieces live). If you use a named container, change the node path here.
	var container: Node2D = get_node_or_null("Pieces") if has_node("Pieces") else self

	# Rect from the sprite (local rect: position & size relative to the sprite)
	var holder_rect: Rect2 = jigsaw_holder_sprite.get_rect()
	var jigsaw_holder_pos_local: Vector2 = holder_rect.position
	var jigsaw_holder_size: Vector2 = holder_rect.size

	# Convert the holder top-left to global coordinates.
	# The sprite's global_position is the sprite's origin (its position), so add the local rect position.
	var holder_top_left_global: Vector2 = jigsaw_holder_sprite.global_position + jigsaw_holder_pos_local

	# Compute grid
	var cols := int(ceil(sqrt(n)))
	var rows := int(ceil(float(n) / cols))

	print("Container Global Position: ", container.global_position)
	print("Holder local rect: ", holder_rect)
	print("Holder top-left (global): ", holder_top_left_global)
	print("Number of Jigsaw pieces: ", n)
	print("Columns: ", cols, " Rows: ", rows)

	# cell size inside the holder
	var cell_size: Vector2 = Vector2(
		jigsaw_holder_size.x / float(cols),
		jigsaw_holder_size.y / float(rows)
	)

	# assign each piece a target position (center of its cell) in global coords
	for i in range(n):
		var piece: Node2D = jigsaw_pieces[i]
		if piece == null:
			continue

		var col = i % cols
		var row = i / cols

		# center of the cell (local to holder top-left)
		var cell_center_local = Vector2(
			col * cell_size.x + cell_size.x * 0.5,
			row * cell_size.y + cell_size.y * 0.5
		)

		# convert to global coordinate (where the piece should snap to)
		var target_global = holder_top_left_global + cell_center_local

		# assign target_position (draggable script expects a global position)
		piece.target_position = target_global
		
		# connecting signal to a function
		piece.placed.connect(add_finished_pieces)

		print("Piece ", i, " -> col:", col, " row:", row, " target(global): ", target_global)

func add_finished_pieces(index):
	finished_pieces.append(index)
	print("Finished Pieces: ", finished_pieces)
	if finished_pieces.size() == jigsaw_pieces.size():
		print("Puzzle Jigsaw Finished")
		emit_signal("puzzle_finished")
		for i in jigsaw_pieces:
			i.visible = false
		$Answer.visible = true

func move_to_center(index):
	print(index)
	var piece: Node2D = jigsaw_pieces[index]
	var distance: Vector2 = container.global_position - piece.global_position
	
	print(container.global_position)
	print(piece.global_position)
	print(distance)
	piece.tween_move_to(piece.global_position + distance, 0.5, false)
