extends Node

@onready var barbarian: CharacterBody3D = $"../Barbarian"
@onready var dialog: Control = $"../UserInterface/Dialog"
@onready var fade: ColorRect = $"../UserInterface/Fade"
@onready var camera: Camera3D = $Camera3D
@onready var _player_camera: Camera3D = $"../Barbarian/CameraHolder/Camera3D"

func position_cinematic_camera_to_match_player_camera():
	camera.move_to_marker(_player_camera)


func fade_to_marker(marker : Node3D) -> Signal:
	await fade.to_black()
	camera.move_to_marker(marker)
	return fade.to_clear()





#func commonly used behaviors():


#after event ends, check for more events and run the next one in the gueue
