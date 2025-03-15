extends Area3D
class_name InteractionEvent


func interact():
	$/root/Game.start_event(self)


func set_interaction(is_interactable : bool):
	collision_layer = 16 if is_interactable else 0
