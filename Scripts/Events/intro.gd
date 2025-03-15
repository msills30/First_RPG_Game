extends ScriptedEvents

func run_event(em : EventManager) -> Signal:
	await em.fade.to_clear()
	await em.dialog.display_line("Hello World")
	File.progress.intro_played = true
	$/root/Game.end_event()
	return super.run_event(em)

