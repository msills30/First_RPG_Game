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
var _relative_velocity : Vector3
var _direction : Vector3
var _wants_to_face_direction : Vector3
var _angle_difference : float 
var _can_move : bool = true:
	set(new_value):
		_can_move = new_value
		if not _can_move:
			_direction = Vector3.ZERO


#Combat Variables
var _target : Node3D
var _locked_on_blend : Vector2
@onready var _unarmed_hit_box: Area3D = get_node_or_null("Rig/HitBox")
@export_flags_3d_physics var _enemy_hurt_layer : int

#Buffered Inputs
var _wants_to_attack : bool
var _wants_to_jump : bool


@onready var _movement_speed : float = _walking_speed

#We could drag and use @onready for the Raycast or
@onready var _interact_range: RayCast3D = get_node_or_null('Rig/RayCast3D')
#@onready var _interact_range: RayCast3D = $Rig/RayCast3D


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



@export_category("Equipment")
@export var _sockets : Array[BoneAttachment3D]
#@export var _attack_animations : Enums.WeaponType
var _attack_animations : Enums.WeaponType
var _main_hand : Node3D
var _off_hand : Node3D

#We to rotate and y with respect to the animation hence why se use the rig 
@onready var _rig: Node3D = $Rig
@onready var _animation: AnimationScript = $AnimationTree as AnimationScript

signal animation_finished(successful : bool)

signal destination_reached

func _ready():
	_min_jump_velocity = sqrt(_min_jump_height * _gravity * _mass * 2)
	_max_jump_velocity = sqrt(_max_jump_height * _gravity * _mass * 2)
	if _unarmed_hit_box:
		_unarmed_hit_box.collision_mask = _enemy_hurt_layer


func animate(animation_name : String, locked : bool = true) -> Signal:
	if _animation:
		if _animation.character_is_in_dialog().get_current_node() != "Locomotion":
			animation_finished.emit(false)
			return animation_finished
	if locked:
		_can_move = false
	if _animation:
		_animation.character_is_in_dialog().travel("Misc/" + animation_name)
		while await _animation.animation_finished != animation_name:
			continue
	if locked:
		_can_move = true
	animation_finished.emit(true)
	return animation_finished

func _stop(instance : Node3D):
	instance.set_physics_process(false)  # Disable physics processing
	if instance.has_method("set_collision_layer"):
		instance.set_collision_layer(0)  # Disable collisions
	if instance.has_method("set_collision_mask"):
		instance.set_collision_mask(0)

func use_item(item : ItemInfo):
	var was_holding : Node3D
	if _sockets[0].get_child_count() > 0:
		was_holding = _sockets[0].get_child(0)
		was_holding.visible = false
	var instance : Node3D = load(item.scene).instantiate()
	_sockets[0].add_child(instance)
	_stop(instance)
	await animate("Use_Item")
	print(name + " used a " + item.name)
	instance.queue_free()
	
	if was_holding:
		was_holding.visible = true 

func don(item : Equipment):
	var instance : Node3D = load(item.scene).instantiate()
	_sockets[item.type].add_child(instance)
	_stop(instance)
	if item is Weapon:
		_main_hand = instance
		_main_hand.set_hit_box_collision_mask(_enemy_hurt_layer)
		_attack_animations = item.weapon_type
		if item.weapon_type == Enums.WeaponType.DUALWIELDING:
			instance = load(item.scene).instantiate()
			_sockets[Enums.EquipmentType.OFF_HAND].add_child(instance)
			_stop(instance)
			_off_hand = instance
			_off_hand.set_hit_box_collision_mask(_enemy_hurt_layer)

func doff(socket : int):
	if socket == Enums.EquipmentType.MAIN_HAND:
		_main_hand = null
		if _attack_animations == Enums.WeaponType.DUALWIELDING:
			doff(Enums.EquipmentType.OFF_HAND)
		_attack_animations = Enums.WeaponType.UNARMED
	elif socket == Enums.EquipmentType.OFF_HAND:
		_off_hand = null
	if _sockets[socket].get_child_count() > 0:
		_sockets[socket].get_child(0).queue_free()

#If you want to radians to be in degrees
#func _ready() -> void:
	#_rotation_speed = deg_to_rad(_rotation_speed)

func face_direction(foward_direction: float):
	_rig.rotation.y = foward_direction 

# Which direction is the character rig facing in global space?
func get_rig_rotation() -> Vector3:
	return _rig.global_rotation


func move(direction : Vector3):
	if not _can_move:
		return
	_direction = direction

func move_to_marker(marker : Node3D, allowable_distance : float = 0.25, running : bool = false) -> Signal:
	var path : Vector3 = marker.global_position - global_position
	var stopping_distance : float
	if running:
		run()
	while path.length() > allowable_distance:
		path = marker.global_position - global_position
		stopping_distance = _xz_velocity.length() / 2 / _deceleration
		_direction = path.normalized() if path.length() > stopping_distance else Vector3.ZERO
		await get_tree().physics_frame
	_direction = Vector3.ZERO
	if running:
		walk()
	destination_reached.emit()
	return destination_reached

func follow_path(path, allowable_distance : float = 0.25, running : bool = false) -> Signal:
	var next_point: int = 0
	while next_point < path.size():
		await move_to_marker(path[next_point], allowable_distance, running)
		next_point += 1
	destination_reached.emit()
	return destination_reached

func snap_to_marker(marker : Node3D, match_y_rotation : bool = true):
	global_position = marker.global_position
	if match_y_rotation:
		_rig.global_rotation = marker.global_rotation


func walk():
	_movement_speed = _walking_speed

func run():
	_movement_speed = _running_speed

#func start_jump():
	#if not _can_move:
		#return
	#if is_on_floor():
		#_state_machine.travel("Jump_Start")
		#_jump_hold.start()
		#_jump_hold.paused = false

func restrict_movement(cannot_move: bool):
	_can_move = not cannot_move

func start_jump():
	_wants_to_jump = true
	_wants_to_attack = false

func complete_jump():
	_jump_hold.paused = true


func apply_jump_velocity():
	_jump_hold.paused = true
	if is_on_floor():
		velocity.y = _min_jump_velocity + (_max_jump_velocity - _min_jump_velocity) * min(1 - _jump_hold.time_left, 0.3) / 0.3

func cancel_jump():
	_wants_to_jump = false

func interact():
	if _interact_range &&  _interact_range.is_colliding() && _interact_range.get_collider().has_method('interact'):
		_interact_range.get_collider().interact()
		

#region Combat

func _on_player_targeted(new_target: Node3D):
	_target = new_target

func attack():
	_wants_to_attack = true
	_wants_to_jump = false

func cancel_attack():
	_wants_to_attack = false

func activate_hit_box(active : bool, which_hand : int = 1):
	match which_hand:
		0:
			_unarmed_hit_box.monitoring = active
		1:
			_main_hand.activate_hit_box(active)
		2:
			_off_hand.activate_hit_box(active)

#endregion


func _physics_process(delta: float):
	if _direction: 
		#Face direction of input or the target
		if _target:
			_wants_to_face_direction = _target.global_position - global_position
		else:
			_wants_to_face_direction = _direction
		_rotate_towards_direction(_wants_to_face_direction, delta)
		# Copy the character's x and z velocity to isolate from y.
	_xz_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if is_on_floor():
		_ground_physics(delta)
	else:
		_air_physics(delta)
	
	#Apply Adjusted xz velocity to the character 
	velocity.x = _xz_velocity.x
	velocity.z = _xz_velocity.z
	
	
	
	if _animation:
		_animation.character_is_moving(velocity != Vector3.ZERO)
	
	move_and_slide()
	

func _rotate_towards_direction(direction : Vector3, delta : float):
	_angle_difference = wrapf(atan2(direction.x, direction.z) - _rig.rotation.y, -PI,PI)
	_rig.rotation.y += clamp(_rotation_speed * delta, 0, abs(_angle_difference)) * sign(_angle_difference)

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
	#Tell animation tree when to blend animations
	_relative_velocity = _xz_velocity / _running_speed
	if _animation:
		if _target:
			_locked_on_blend.x = _rig.global_basis.x.dot(_relative_velocity) * -1
			_locked_on_blend.y = _rig.global_basis.z.dot(_relative_velocity) 
			_animation.set_locked_on_blend(_locked_on_blend)
			#_animation.set('parameters/Movement/Locomotion/Locked_On/blend_position',_locked_on_blend)
		else:
			_animation.set_not_locked_on_blend(_relative_velocity.length())
		#_animation.set('parameters/Movement/Locomotion/Not_Locked_On/blend_position',_relative_velocity.length())
	


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



