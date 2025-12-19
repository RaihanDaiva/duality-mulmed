extends Node

var current_subscene: String = "" #scene(angka)
var current_room: String = "" #nama ruangan
var quest_bed_done: String = "" #start, not yet, done
var quest_car_done: String = ""
var quest_title: String = ""


#scene 2
var quest_dead_body_done: bool
var police_left_talked: bool
var police_right_talked: bool
var police_gang_talked: bool
var give_puzzle_to_police_scene_3: bool
var puzzle_scene2: bool

#scene 6
var quest_bed: bool

#scene 7
var quest_table_done: String = ""

#scene 8
var quest_chair_done: bool

#scene 9
var quest_severed_done: String = ""
var quest_lengan_done: bool
var scene9_give_evidence: bool = false

#scene 10
var puzzle_scene10: bool

#scene 11
var have_key: bool

#scene 12
var have_feet: bool = false
var scene12_give_evidence: bool = false

#scene 14
var puzzle_scene14: bool

#scene 15 part 2
var grey_entering_car: bool

#scene 16
var last_quest: bool
var entered_house: bool

#scene 17
var quest_hole: bool


#scene 19
var entered_operating_room: bool
var first_dialogue: bool

#scene 20
var quest_half_body: bool

func debug_current_scene():
	print("\n<===== Debugging Current Level/Scene Position START =====>")
	print("current_subscene : ", current_subscene)
	print("current_room : ", current_room)
	print("<===== Debugging Current Level/Scene Position END =====>\n")

# Quest Title Global Test
var load_quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
var quest_title_instance_global = load_quest_title.instantiate()


func setup_quest_title(target_node: Node):
	#	Setup quest_title
	var load_quest_title = preload("res://UI/PlayingInterface/QuestTitle.tscn")
	var instance = load_quest_title.instantiate()
	quest_title_instance_global = instance
	target_node.add_child(instance)

func set_quest_title(root_node:Node, animate: bool):
	for node in root_node.get_children():
		if node == quest_title_instance_global:
			var quest_title_node = node
			quest_title_node._update_quest_title(quest_title, animate)
