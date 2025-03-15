extends Control
class_name Counter

@export var on_screen_position : Vector2 
@export var off_screen_position : Vector2 
@export var _duration : float = 1
@export var _trans_type : Tween.TransitionType


@onready var _icon: TextureRect = $Icon
@onready var _counter: Label = $Counter
@onready var _auto_hide: Timer = $AutoHide
@onready var _sfx: AudioStreamPlayer = $AudioStreamPlayer
@onready var _particles_2d: CPUParticles2D = $CPUParticles2D


var _tween : Tween
var is_open : bool 
var stay_open : bool


func open(stay_open : bool = true):
	stay_open = stay_open
	await _tween_position(on_screen_position, Tween.EASE_OUT)
	is_open = true
	return _tween.finished

func set_value(new_value : int):
	if not is_open:
		await open(false)
	await _pulse
	_sfx.play()
	_particles_2d.emitting = true
	_counter.text = str(clamp(new_value, 0,999999))
	if not stay_open:
		_auto_hide.start()

func _pulse() -> Signal:
	if _tween && _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_icon, "custom_minimum_size:y", 47, 0.1)
	_tween.tween_property(_icon, "custom_minimum_size:y", 42, 0.1)
	return _tween.finished

func close() -> Signal:
	is_open = false
	_tween_position(off_screen_position, Tween.EASE_IN)
	return _tween.finished

func _tween_position(new_position : Vector2, ease_type : Tween.EaseType) -> Signal:
	if _tween && _tween.is_running():
		_tween.kill()
	_tween = create_tween().set_trans(_trans_type).set_ease(ease_type)
	_tween.tween_property(self, "position", new_position, _duration)
	return _tween.finished 
	
