extends Item

@onready var _hit_box: Area3D = $HitBox

func set_hit_box_collision_mask(mask : int):
	_hit_box.collision_mask = mask

func activate_hit_box(active : bool):
	_hit_box.monitorable = active
