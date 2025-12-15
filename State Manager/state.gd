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

#scene 10
var puzzle_scene10: bool

#scene 11
var have_key: bool

#scene 12
var have_feet: bool

#scene 14
var puzzle_scene14: bool

#scene 15 part 2
var grey_entering_car: bool

#scene 16
var last_quest: bool
var entered_house: bool

func debug_current_scene():
	print("<===== Debugging Current Level/Scene Position START =====>")
	print("current_subscene", current_subscene)
	print("current_room", current_room)
	print("<===== Debugging Current Level/Scene Position END =====>")
