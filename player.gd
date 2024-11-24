extends Node

@export var _character : CharacterBody3D
@export var _camera : Camera3D

var _input_direction : Vector2
var _move_direction : Vector3

#left (-1,0) right(1,0) forward(0,-1) backward(0,1)
#we use _delta not delta to avoid the error of key frames not being used
#If we do are using keyframes then use delta 


func _process(_delta: float) -> void:
	_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	_move_direction = (_camera.basis.x * Vector3(1, 0, 1)).normalized() * _input_direction.x
	_move_direction += (_camera.basis.z * Vector3(1, 0, 1)).normalized() * _input_direction.y
	_character.move(_move_direction)
	


