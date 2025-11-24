extends StaticBody2D

@onready var interaction_area = $InteractionArea
@onready var sprite = $Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	interaction_area.interact = Callable(self, "_chest")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _chest():
	sprite.frame = 27 if sprite.frame == 0 else 0
