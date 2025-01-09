extends Node

const SETTINGS_PATH : String = "user://settings.tres"
const SAVE_PATH : String = "user://save.res"

var settings : Settings
var progress : Progress

func _ready():
	#if settings exist
	if ResourceLoader.exists(SETTINGS_PATH):
		#load settings
		settings = ResourceLoader.load(SETTINGS_PATH)
	else:
		settings = Settings.new()
		#save settings
		ResourceSaver.save(settings, SETTINGS_PATH)


func save_settings():
	ResourceSaver.save(settings, SETTINGS_PATH)


func save_file_exist() -> bool:
	return ResourceLoader.exists(SAVE_PATH)


func new_game():
	progress = Progress.new()


func save_game():
	ResourceSaver.save(progress, SAVE_PATH)


func load_game():
	progress = ResourceLoader.load(SAVE_PATH)
