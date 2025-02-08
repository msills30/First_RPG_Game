extends Area3D

@onready var gm = $/root/Game

func run_event(_em):
	await _em.dialog.display_line("You have entered the Mage's room")
	#who is saying what
	#how are they saying it
	#what is the camera looking at
	#
	gm.end_event()

func _on_body_entered(_body: Node3D):
	gm.start_event(self)
