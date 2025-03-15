extends Area3D
class_name ProximityEvent

func _ready():
	body_entered.connect(_on_body_entered)
	
	#collision_layer = 9, SOMETHING * 2^8
	collision_mask = 256


func _on_body_entered(body : Node3D):
	$/root/Game.start_event(self)

func disable():
	collision_mask = 0

