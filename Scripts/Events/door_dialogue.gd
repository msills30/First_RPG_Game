extends InteractionEvent

@onready var _door: Node3D = get_parent()
@onready var _rogue_markers: Array[Node] = $RogueMarkers.get_children()
@onready var _rogue_hooded: CharacterBody3D = $"../../NPC/Rogue_Hooded"

#Sense we are using the InteractionEvent we don't need the func interact()

#func interact():
	#$/root/Game.start_event(self)
	#

#Remember its $/root/Game not $root/Gm

func run_event(em : EventManager):
	await em.barbarian.animate("Interact")
	if _door.is_open():
		$/root/Game.end_event()
		set_interaction(false)
		await _door.close()
		set_interaction(true)
	else:
		set_interaction(false)
		_door.open()
		#In the collision layer the value is 16 hence collision layer  = 16
		collision_layer = 16
		await em.barbarian.move_to_marker(_rogue_markers[0])
		await em.dialog.display_line("Thanks", "Rogue")
		$/root/Game.end_event()
		await _rogue_hooded.follow_path(
			[
				_rogue_markers[1],
				_rogue_markers[2],
				_rogue_markers[3]
			],
			0.5,
			true
		)
		set_interaction(true)




#func run_event(em):
	#await em.barbarian.animate("Interact")
	#if _door.is_open():
		#$/root/Game.end_event()
		#collision_layer = 0
		#await _door.close()
		#collision_layer = 16
		#return
	#else:
		#if File.progress.knows_the_password:
			#await em.dialog.display_line("Ahem...\n[color=blue]Password![/color]")
			#$/root/Game.end_event()
			#collision_layer = 0
			#await _door.open()
			##In the collision layer the value is 16 hence collision layer  = 16
			#collision_layer = 16
			#return
		#else:
			#await em.dialog.display_line("There is a door, but its locked ")
	#$/root/Game.end_event()
