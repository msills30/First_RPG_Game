extends Node

@export var _character : CharacterBody3D
@export var _camera_holder : SpringArm3D
@export var _camera : Camera3D
@onready var _game_manager : Node3D = $/root/Game
@onready var _pick_up_radius: Area3D = $"../Barbarian/PickUpRadius"
@onready var _inventory: Control = %Inventory


var _nearest_item : Node3D
var _input_direction : Vector2
var _move_direction : Vector3
var enabled : bool = true:
	set(new_value):
		enabled = new_value
		#stop character from moving after player control is disabled
		if not enabled:
			_character.move(Vector3.ZERO)

#left (-1,0) right(1,0) forward(0,-1) backward(0,1)
#we use _delta not delta to avoid the error of key frames not being used
#If we do are using keyframes then use delta 


func face_direction(foward_direction: float):
	_camera_holder.rotation.y = foward_direction + PI
	_character.face_direction(foward_direction)

func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		_game_manager.toggle_pause()
	if get_tree().paused:
		return
	if event.is_action_pressed("inventory"):
		_game_manager.toggle_inventory()
	if not enabled:
		return
	elif event.is_action_pressed("run"):
		_character.run()
	elif event.is_action_released("run"):
		_character.walk()
	elif event.is_action_pressed('jump'):
		_character.start_jump()
	elif event.is_action_released("jump"):
		_character.complete_jump()
	elif event.is_action_pressed("interact"):
		_nearest_item = _pick_up_radius.get_nearest_item()
		if _nearest_item:
			_inventory.add_item(_nearest_item.resource)
			_nearest_item.queue_free()
		else:
			_character.interact()
 

func _process(_delta: float) -> void:
	if get_tree().paused || not enabled:
		return
	_camera_holder.look(Input.get_vector("look_left", "look_right", "look_up", "look_down"))
	_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	_move_direction = (_camera_holder.basis.x * Vector3(1, 0, 1)).normalized() * _input_direction.x
	_move_direction += (_camera_holder.basis.z * Vector3(1, 0, 1)).normalized() * _input_direction.y
	_character.move(_move_direction)
	


