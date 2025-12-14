extends Node2D

var quest_title_instance
var dialogue_active = false

func _ready() -> void:
	await get_tree().process_frame
	_talk()
	State.current_subscene = "scene2"
	
	#	Setup quest_title
	var quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
	quest_title_instance = quest_title.instantiate()
	$"TKP 1 KP 1/Environment/Cars2/InteractionArea/CollisionShape2D".disabled = true
	
func _talk():
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	player.can_move = false
	player.direction = Vector2.ZERO
	dialogue_active = true
		
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished, CONNECT_ONE_SHOT)
		
	await get_tree().create_timer(1).timeout
	DialogueManager.show_dialogue_balloon(
		load("res://Scene/Scene 2/Dialogue/dennis.dialogue"),
		"start"
	)

func _on_dialogue_finished(resource):
	add_child(quest_title_instance)
	change_quest_title("Hampiri Mayat")
	
	print("before",NavigationManager.spawn_door_tag)
	NavigationManager.spawn_door_tag = null
	print("after",NavigationManager.spawn_door_tag)
	
	# Contoh update state punyamu
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		dialogue_active = false
		player.can_move = true
	

func change_quest_title(new_title: String) -> void:
	quest_title_instance._update_quest_title(new_title, true)
