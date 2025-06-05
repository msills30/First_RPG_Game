extends Node

@export var _character : CharacterBody3D
@export var _camera_holder : SpringArm3D
@export var _camera : Camera3D
@onready var _game_manager : Node3D = $/root/Game
@onready var _pick_up_radius: Area3D = $"../Barbarian/PickUpRadius"
@onready var _inventory: Control = %Inventory
@onready var _target_indicator: Sprite3D = $TargetIndicator
@onready var _input_buffer: Timer = $InputBuffer


var _target : Node3D:
	set(new_target):
		_target = new_target
		targeted.emit(_target)

var _nearest_item : Node3D
var _input_direction : Vector2
var _move_direction : Vector3
var enabled : bool = true:
	set(new_value):
		enabled = new_value
		#stop character from moving after player control is disabled
		if not enabled:
			_character.move(Vector3.ZERO)

signal targeted(new_target : Node3D)


#left (-1,0) right(1,0) forward(0,-1) backward(0,1)
#we use _delta not delta to avoid the error of key frames not being used
#If we do are using keyframes then use delta 


func face_direction(foward_direction: float):
	_camera_holder.rotation.y = foward_direction + PI
	_character.face_direction(foward_direction)

#This input controls the camera 
func _camera_input(event : InputEvent):
	if  not _target and event is InputEventMouseMotion:
		_camera_holder.look(event.relative * get_process_delta_time())
	if event.is_action_pressed('toggle_lock'):
		if _target:
			#if pressing down, force lock off
			if _input_direction.dot(Vector2.DOWN) > 0.75:
				toggle_lock(true)
			else:
				toggle_lock()
		else:
			toggle_lock()
			if not _target:
				_camera_holder.position_camera_behind_character()

func toggle_lock(force_off : bool = false):
	_target = null if force_off else _camera.get_nearest_visible_target(_target)
	if _target:
		_target_indicator.reparent(_target)
		_target_indicator.position = Vector3.UP * 3
		_target_indicator.visible = true
	else:
		_target_indicator.reparent(self)
		_target_indicator.visible = false

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
		#_character.take_damage(2)
		_character.walk()
	
	elif event.is_action_pressed("attack"):
		_character.attack()
		_input_buffer.start()
		await _input_buffer.timeout
		_character.cancel_attack()
		
	elif event.is_action_pressed("dodge"):
		_character.dodge()
		_input_buffer.start()
		await _input_buffer.timeout
		_character.cancel_dodge()
	
	if event.is_action_pressed('block'):
		_character.block(true)
	elif event.is_action_released('block'):
		_character.block(false)
	
	elif event.is_action_pressed('jump'):
		_character.start_jump()
		_input_buffer.start()
		await _input_buffer.timeout
		_character.cancel_jump()
	
	elif event.is_action_released("jump"):
		_character.complete_jump()
	
	elif event.is_action_pressed("interact"):
		_nearest_item = _pick_up_radius.get_nearest_item()
		if _nearest_item:
			_inventory.add_item(_nearest_item.resource)
			_nearest_item.queue_free()
		else:
			_character.interact()
	if enabled:
		_camera_input(event)
 

func _process(_delta: float):
	if get_tree().paused || not enabled:
		return
	
	if not _target:
		_camera_holder.look(Input.get_vector("look_left", "look_right", "look_up", "look_down"))
	
	#Character_moverment
	_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	_move_direction = (_camera_holder.basis.x * Vector3(1, 0, 1)).normalized() * _input_direction.x
	_move_direction += (_camera_holder.basis.z * Vector3(1, 0, 1)).normalized() * _input_direction.y
	_character.move(_move_direction)
	


