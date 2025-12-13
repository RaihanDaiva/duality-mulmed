extends Node2D

var quest_title_instance

func _ready() -> void:
	State.current_subscene = "scene2"
	#	Setup quest_title
	var quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
	quest_title_instance = quest_title.instantiate()
	add_child(quest_title_instance)
	change_quest_title("Hampiri Mayat")
	$"TKP 1 KP 1/Environment/Cars2/InteractionArea/CollisionShape2D".disabled = true
	

func change_quest_title(new_title: String) -> void:
	quest_title_instance._update_quest_title(new_title, true)
