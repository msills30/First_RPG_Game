extends Resource
class_name Settings

@export var camera_invert_x : bool
@export var camera_invert_y : bool
@export var volume : float

func _init():
	camera_invert_x = false
	camera_invert_y = true
	volume = 0.5