extends Resource
class_name Progress

#You would use for creating save points which are found in most rpg games
#@export var save_point_id : int 
@export var current_level : String
@export var transition_id : int
@export var times_spoken_to_npc : Array[int]
@export var knows_the_password : bool
@export var intro_played : bool
@export var coins : int:
	set(new_value):
		if coins != new_value:
			coins = new_value
			Global.coins_updated.emit(coins) 

@export var inventory : Array = []


func _init():
	current_level = 'dungeon_1'
	transition_id = 0
	times_spoken_to_npc = [0, 0, 0]
	coins = 0
	inventory = [
		{"name" : "Health Potion", "quantity" : 98},
		{"name" : "Axe"},
		{"name" : "Axe"}
	]


