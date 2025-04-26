extends InteractionEvent


@onready var _camera_markers: Array[Node] = $CameraMarkers.get_children()
@onready var _path_follow: PathFollow3D = $Path3D/PathFollow3D
@onready var _mage: CharacterBody3D = get_parent()
@onready var _movement_markers : Array[Node] = $MovementMarkers.get_children()


#func _ready():
	#set_interaction(not File.progress.player_has_key)
	

func  run_event(em : EventManager):
	await em.fade.to_black()
	em.barbarian.snap_to_marker(_movement_markers[2])
	await em.fade.to_clear()
	await em.dialog.display_line("You'll need a key for that, hold on a second", "Mage")
	await _mage.move_to_marker(_movement_markers[1])
	await _mage.animate("Interact")
	await _mage.move_to_marker(_movement_markers[0])
	_mage.animate("Interact")
	await em.dialog.display_line("Here it is. Good luck buddy", "Mage")
	#File.progress.player_has_key = true
	#set_interaction(false)
	$/root/Game.end_event(true) 


#func run_event(em: EventManager):
	##await em.fade_to_marker(_camera_markers[0])
	#await em.position_cinematic_camera_to_match_player_camera()
	#em.camera.pan_to_marker(_camera_markers[0], 5)
	#await em.dialog.display_line("Who are you and what are you doing here?", "Mage")
	#_mage.animate("Cheer")
	#await em.dialog.display_line("[shake]GET OUT OF MY STUDY AREA!! >:", "Mage")
	#$/root/Game.end_event(true) 

#func run_event(em):
	#await em.fade_to_marker(_path_follow)
	#await em.dialog.display_line("Did you see that dangerous criminal locked up in that cell?", "Mage")
	#em.camera.follow_path(_path_follow,10)
	#await em.dialog.display_line("You can see through it by window in the guard chamber.", "Mage")
	#await em.dialog.display_line("Rumor has it he murdered someone without any remorse.", "Mage")
	#em.camera.pan_direction(Vector3.UP, 1)
	#$/root/Game.end_event(true) 

#func run_event(em):
	#await em.position_cinematic_camera_to_match_player_camera()
	#em.camera.pan_to_marker(_camera_markers[0], 5)
	#match await em.dialog.display_options(
		#"What do you want sir?",
		#[
			#"I'm here to see the prisoner.",
			#"Nothing much just saying hello friend :)"
		#],
	#):
		#0:
			#await em.dialog.display_multiline(
				#[
					#"Alright the guards told me you were coming.",
					#"The password to open the is",
					#"[color=blue]Password[/color]."
				#],
				#"Mage"
			#)
			#File.progress.knows_the_password = true
		#1:
			#await em.dialog.display_line(
				#"Stop wasting my time! \nCan't you see that I'm busy >:(", "Mage"
			#)
	#em.camera.pan_direction(Vector3.UP, 1)
	#$/root/Game.end_event(true)


#func run_event(_em):
	#await _em.dialog.display_multiline(
		#[
			#"Hello the I am mage",
			#"Don't bother looking at that conspicuous wall over there."
		#],
			#"Mage"
	#)
	#await _em.dialog.display_line("That's not suspicuous at all.","Barbarian")
	#$/root/Game.end_event()

#func run_event(em):
	#match await em.dialog.display_options(
		#"Hello I came back from the store. What do you think about my outfit?",
		#[
			#"You look fantastic",
			#"The hat is a little bit too much",
			#"No offense but the outfit looks cheap"
		#]
	#):
		#0:
			#await em.dialog.display_line("Thanks! I think so too.", "Mage")
		#1:
			#await em.dialog.display_line("...You're probably right, I might have spent a bit too much. \nMaybe I can return it for a discount.", "Mage")
		#2:
			#await em.dialog.display_line("Well the purple hat was the cheapest I can afford.\n","Mage")
	#$/root/Game.end_event()
	

#func run_event(em):
	#match File.progress.times_spoken_to_npc[Enums.NPC.MAGE]:
		#0:
			#await em.dialog.display_line("Hello, nice to meet you buddy. \nMy name is [color=purple]Jorel[/color].\nI am the magical advisor.", "Mage")
			#File.progress.times_spoken_to_npc[Enums.NPC.MAGE] += 1
		#1:
			#await em.dialog.display_line("Feel free to look around. \n Remember don't touch anything.", "Jorel")
			#File.progress.times_spoken_to_npc[Enums.NPC.MAGE] += 1
		#2:
			#await em.dialog.display_line("I'm sorry but I'm busy at the moment. \n Feel free to look around pal." , "Jorel")
			#File.progress.times_spoken_to_npc[Enums.NPC.MAGE] += 1
	#
	#$/root/Game.end_event()
