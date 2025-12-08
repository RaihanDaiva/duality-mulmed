extends Node2D

var quest_title_instance

func _ready() -> void:
	#	Setup quest_title
	var quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
	quest_title_instance = quest_title.instantiate()
	add_child(quest_title_instance)
	change_quest_title("Hampiri Mayatad")

func change_quest_title(new_title: String) -> void:
	quest_title_instance._update_quest_title(new_title)
