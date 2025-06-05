extends SceneManager

@onready var _player: Node = $Player
@export var _character: CharacterBody3D
@onready var _pause_menu : Control = $UserInterface/PauseMenu
#@onready var _dialog: Control = $UserInterface/Dialog
@onready var _event_manager: EventManager = $EventManager
@onready var _camera: Camera3D = $Barbarian/CameraHolder/Camera3D
@onready var _intro_event: ScriptedEvents = $Intro
@onready var _inventory: Panel = %Inventory


var _current_level: Node3D 

func _ready():
	load_level()
	if not File.progress.intro_played:
		start_event(_intro_event)
		await _intro_event.finished
	else:
	
		super._ready()
	#_dialog.display_multiline(
		#[
			#"Greetings I have a quest for you I want to you to eat this not poisonous and apple and beat up a monster for my amusement lol.",
			#"But before I send to my fun and amazing quest I shall show you my amazing dance don't you'll miss it.",
			#"......................",
			#"Looks like you missed, its alright it takes good eyesight see my faster than light dance moves."
		#],
		#"A Very Important Person"
	#)
	

func start_event(event, disable_player : bool = true):
	if not event || not event.has_method('run_event'):
		push_warning('Event : ' + event + 'does not have run_event method.')
		return
	if disable_player:
		_player.enabled = false
	event.run_event(_event_manager)

func end_event(use_fade : bool = false):
	if _event_manager.camera.current:
		if use_fade:
			await _fade.to_black()
		_camera.make_current()
		_event_manager.camera.reparent(_event_manager)
		if use_fade:
			await _fade.to_clear()
	_player.enabled = true


func load_level():
	if _current_level:
		File.save_game()
		await _fade.to_black()
		_current_level.queue_free()
	_current_level = load("res://Scenes/Levels/" + File.progress.current_level + ".tscn").instantiate()
	add_child(_current_level)
	_character.position = _current_level.get_entrance(File.progress.transition_id)
	_character.face_direction(_current_level.get_foward_direction(File.progress.transition_id))
	_current_level.activate_transition()
	await _fade.to_clear()

func toggle_pause():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		_pause_menu.open()
	else:
		_pause_menu.close()

func toggle_inventory():
	if _inventory.is_open:
		_inventory.close()
	else:
		_inventory.open_as_inventory()

func _on_exit_pressed():
	change_scene('res://Scenes/title.tscn')



func _on_settings_pressed():
	_settings_menu.open(_pause_menu)



func _on_character_died():
	await _fade.to_black()
	change_scene('res://Scenes/title.tscn')
