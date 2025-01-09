extends CharacterBody3D

#_name prevents other scripts from accessing this 

@export_category("Locomotion")
@export var _walking_speed : float = 1
@export var _running_speed : float = 2
@export var _acceleration : float = 2
@export var _deceleration : float = 4
#rotation is measured in radians
@export var _rotation_speed : float = PI * 2
var _xz_velocity : Vector3
var _direction : Vector3
var _angle_difference : float 

@onready var _movement_speed : float = _walking_speed



@export_category("Jumping")
@export var _min_jump_height : float = 0.5
@export var _max_jump_height : float = 2.5
@export var _air_control : float = 0.5
@export var _air_brakes : float = 0.5

@export var _mass : float =  1
@onready var _jump_hold: Timer = $JumpHold
var _min_jump_velocity : float
var _max_jump_velocity : float

var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


@onready var _animation: AnimationTree = $AnimationTree
#We to rotate and y with respect to the animation hence why se use the rig 
@onready var _rig: Node3D = $Rig
@onready var _state_machine : AnimationNodeStateMachinePlayback = _animation['parameters/playback']


func _ready():
	_min_jump_velocity = sqrt(_min_jump_height * _gravity * _mass * 2)
	_max_jump_velocity = sqrt(_max_jump_height * _gravity * _mass * 2)

#If you want to radians to be in degrees
#func _ready() -> void:
	#_rotation_speed = deg_to_rad(_rotation_speed)

func face_direction(foward_direction: float):
	_rig.rotation.y = foward_direction 

func move(direction : Vector3):
	_direction = direction

func walk():
	_movement_speed = _walking_speed

func run():
	_movement_speed = _running_speed

func start_jump():
	if is_on_floor():
		_state_machine.travel("Jump_Start")
		_jump_hold.start()
		_jump_hold.paused = false

func complete_jump():
	_jump_hold.paused = true

func apply_jump_velocity():
	_jump_hold.paused = true
	if is_on_floor():
		velocity.y = _min_jump_velocity + (_max_jump_velocity - _min_jump_velocity) * min(1 - _jump_hold.time_left, 0.3) / 0.3
	


func _physics_process(delta: float):
	if _direction: 
		_angle_difference = wrapf(atan2(_direction.x, _direction.z) - _rig.rotation.y, -PI,PI)
		_rig.rotation.y += clamp(_rotation_speed * delta, 0, abs(_angle_difference)) * sign(_angle_difference)
		# Copy the character's x and z velocity to isolate from y.
	_xz_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)
	
	#Apply Adjusted xz velocity to the character 
	velocity.x = _xz_velocity.x
	velocity.z = _xz_velocity.z
	
	move_and_slide()
	

func _ground_physics(delta: float):
		#Apply movement to the xz input  
	if _direction:
		#Accelerate
		if _direction.dot(velocity) >= 0:
			_xz_velocity = _xz_velocity.move_toward(_direction * _movement_speed, _acceleration * delta)
		#Turn Around
		else:
			_xz_velocity = _xz_velocity.move_toward(_direction * _movement_speed, ( _deceleration * 5) * delta)
	
	#Decelerate
	else:
		_xz_velocity = _xz_velocity.move_toward(Vector3.ZERO, _deceleration * delta)
	
	_animation.set('parameters/Locomotion/blend_position',_xz_velocity.length()/ _running_speed)


func _air_physics(delta: float):
	# add gravity
	velocity.y -= _gravity * _mass * delta
	if _direction:
		#Accelerate
		if _direction.dot(velocity) >= 0:
			_xz_velocity = _xz_velocity.move_toward(_direction * _movement_speed, _acceleration * _air_control * delta)
		#Turn Around
		else:
			_xz_velocity = _xz_velocity.move_toward(_direction * _movement_speed, ( _deceleration * 5)* _air_control  * delta)
	
	#Decelerate
	else:
		_xz_velocity = _xz_velocity.move_toward(Vector3.ZERO, _deceleration * _air_brakes * delta)






