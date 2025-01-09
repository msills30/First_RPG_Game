extends Resource
class_name Progress

#You would use for creating save points which are found in most rpg games
#@export var save_point_id : int 
@export var current_level : String
@export var transition_id : int

func _init():
	current_level = 'dungeon_1'
	transition_id = 0
	

