extends SpringArm3D

@export var _rotation_speed : float = 1
@export var _min_rotation : float = -PI/3
@export var _max_rotation : float = PI/15
@export var _reset_x_rotation : float = -0.5
@export var _duration : float = 0.25
@onready var _character : CharacterBody3D = get_parent()

var _target_rotation : Vector3 = Vector3(_reset_x_rotation, 0, 0)
var _tween : Tween

func look(direction : Vector2):
	#vertical y rotation
	rotation.x += direction.y * _rotation_speed * get_process_delta_time() * (1 if File.settings.camera_invert_y else -1)
	rotation.x = clampf(rotation.x, _min_rotation, _max_rotation)
	#horizontal x rotation
	rotation.y += direction.x * _rotation_speed * get_process_delta_time()* (1 if File.settings.camera_invert_x else -1)

func position_camera_behind_character(duration : float = _duration):
	_tween_rotation(_character.get_rig_rotation().y + PI, duration)

func _tween_rotation(target_y_rotation : float, duration : float = _duration):
	_target_rotation.y = wrapf(target_y_rotation, rotation.y - PI, rotation.y + PI)
	if _tween && _tween.is_running():
		_tween.kill()
		_tween = create_tween()
		_tween.tween_property(self, "rotation",_target_rotation, duration)
