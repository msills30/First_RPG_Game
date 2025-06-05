extends Node3D

@onready var _character : CharacterBody3D = get_parent()
@onready var _line_of_sight: RayCast3D = $FieldOfVision/LineOfSight
@onready var _field_of_vision: Area3D = $FieldOfVision
var _target : CharacterBody3D
var _has_seen_target : bool


func _ready():
	_character.died.connect(stop_action)


func _process(_delta: float):
	rotation.y = _character.get_rig_rotation().y
	if not _target:
		return
	if not _has_seen_target:
		_line_of_sight.target_position = _target.global_position + Vector3.UP - global_position
		_line_of_sight.force_raycast_update()
		if _line_of_sight.is_colliding() and _line_of_sight.get_collider() == _target:
			_has_seen_target = true
			_target.died.connect(stop_action)
		else:
			#chase and attack
			var direction = (_target.global_position - _character.global_position).normalized()
			_character.move(direction)

func stop_action():
	_target = null
	_has_seen_target = false
	_character.move(Vector3.ZERO)
	_field_of_vision.monitoring = false

func _on_attack_range_area_entered(hurt_box: Area3D):
	_character.attack()


func _on_attack_range_area_exited(hurt_box: Area3D):
	_character.cancel_attack()


func _on_field_of_vision_body_entered(body: Node3D):
	_target = body


func _on_field_of_vision_body_exited(body: Node3D):
	if body == _target and not _has_seen_target:
		_target = null
