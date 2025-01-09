extends SceneManager

@onready var _menu_buttons : Control =  $MenuButtons
@onready var _continue_button: Button = $MenuButtons/Continue


func _ready():
	super._ready()
	_menu_buttons.open()
	if File.save_file_exist():
		_continue_button.disabled = false
		_continue_button.grab_focus()

func _on_new_game_pressed() -> void:
	File.new_game()
	change_scene("res://game/game.tscn")


func _on_continue_pressed() -> void:
	File.load_game()
	change_scene("res://game/game.tscn")


func _on_settings_pressed() -> void:
	_settings_menu.open(_menu_buttons)


func _on_credits_pressed() -> void:
	change_scene("res://Scenes/credits.tscn")


func _on_exit_pressed() -> void:
	await _fade.to_black()
	get_tree().quit()
