extends SceneManager

@onready var _player: Node = $Player
@onready var _character: CharacterBody3D = $Barbarian
@onready var _pause_menu : Control = $UserInterface/PauseMenu
var _current_level: Node3D 

func _ready():
	load_level()
	super._ready()

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


func _on_exit_pressed():
	change_scene('res://Scenes/title.tscn')


func _on_settings_pressed():
	_settings_menu.open(_pause_menu)
