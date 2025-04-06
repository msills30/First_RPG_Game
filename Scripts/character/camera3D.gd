extends Camera3D

@onready var _line_of_sight: RayCast3D = $LineOfSight

var _visible_target : Array[Node3D] = []
var _current_distance : float
var _nearest_distance : float
var _nearest_index : int


func get_nearest_visible_target(current_target : Node3D = null) -> Node3D:
	if _visible_target.size() == 0:
		return null
	_nearest_distance = INF
	_nearest_index = -1
	
	for i in _visible_target.size():
		if _visible_target[i] == current_target:
			continue
		_current_distance = global_position.distance_squared_to(_visible_target[i].global_position)
		if _current_distance < _nearest_distance:
			_line_of_sight.global_rotation = Vector3.ZERO
			_line_of_sight.global_position = _visible_target[i].global_position + Vector3.UP - global_position
			_line_of_sight.force_raycast_update()
			if _line_of_sight.get_collider() == _visible_target[i]:
				print('hello')
				_nearest_distance = _current_distance
				_nearest_index = i
	if _nearest_index == -1:
		return null
	else:
		return _visible_target[_nearest_index]


func _on_target_range_body_entered(body: Node3D):
	_visible_target.append(body)


func _on_target_range_body_exited(body: Node3D):
	_visible_target.erase(body)
