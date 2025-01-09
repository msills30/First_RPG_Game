extends ColorRect

@export var _duration : float = 1
const CLEAR: Color = Color(0,0,0,0)
var _tween : Tween # in between

func _ready():
	visible = true

func to_clear(duration : float = _duration) -> Signal:
	return to_color(CLEAR, duration)

func to_black(duration : float = _duration) -> Signal:
	return to_color(Color.BLACK, duration)

func to_color(new_color: Color, duration : float = _duration) -> Signal:
	if _tween && _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, 'color',new_color, duration)
	return _tween.finished
