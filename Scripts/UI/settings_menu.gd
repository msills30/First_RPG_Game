extends Menu

signal volume_changed(new_volume : float)

@onready var _camera_invert_x: CheckBox = $VBoxContainer/GridContainer/CameraInvertX
@onready var _camera_invert_y: CheckBox = $VBoxContainer/GridContainer/CameraInvertY
@onready var _master_volume: HSlider = $VBoxContainer/GridContainer/MasterVolume
@onready var _muisc_volume: HSlider = $VBoxContainer/GridContainer/MuiscVolume
@onready var _sfx_volume: HSlider = $VBoxContainer/GridContainer/SFXVolume

@onready var _typing_speed: HSlider = $VBoxContainer/GridContainer/TypingSpeed



func _ready():
	_camera_invert_x.button_pressed = File.settings.camera_invert_x
	_camera_invert_y.button_pressed = File.settings.camera_invert_y
	_master_volume.value = File.settings.master_volume
	_muisc_volume.value = File.settings.music_volume
	_sfx_volume.value = File.settings.sfx_volume
	_typing_speed.value = File.settings.typing_speed
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(File.settings.master_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(File.settings.music_volume))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(File.settings.sfx_volume))
	#Music.set_linear_volume(File.settings.volume)
	#volume_changed.emit(File.settings.volume)
#


func _on_camera_invert_x_toggled(toggled_on: bool):
	File.settings.camera_invert_x = toggled_on


func _on_camera_invert_y_toggled(toggled_on: bool):
	File.settings.camera_invert_y = toggled_on


func _on_master_volume_value_changed(value: float):
	File.settings.master_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(File.settings.master_volume))
	#Music.set_linear_volume(value)
	#volume_changed.emit(value)
	#emit a signal that any audio node can connect to 

func _on_music_volume_value_changed(value: float):
	File.settings.music_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(File.settings.music_volume))

func _on_sfx_volume_value_changed(value: float):
	File.settings.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(File.settings.sfx_volume))


func _on_typing_speed_changed(value: float):
	@warning_ignore('narrowing_conversion')
	File.settings.typing_speed = value

func close():
	File.save_settings()
	super.close()



