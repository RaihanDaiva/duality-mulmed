extends CanvasLayer

var quest_is_hidden: bool = true
@export var quest_name: String = "Quest Name"

func _ready() -> void:
	$Sprite2D/HBoxContainer/QuestName.text = quest_name

func _input(event) -> void:	
	if event.is_action_pressed("quest_button"):
		if quest_is_hidden:
			quest_is_hidden = false
			$AnimationPlayer.play("hide_quest_title")
		else:
			quest_is_hidden = true
			$AnimationPlayer.play("show_quest_title")

func _update_quest_title(title: String, anim: bool):
	$Sprite2D/HBoxContainer/QuestName.text = title
	
	quest_is_hidden = true
	
	if anim:
		$AnimationPlayer.play("show_quest_title")
