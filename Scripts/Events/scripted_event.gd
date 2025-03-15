extends Node
class_name ScriptedEvents

signal finished

func run_event(_em : EventManager) -> Signal:
	finished.emit()
	return finished

