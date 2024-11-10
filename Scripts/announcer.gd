extends AudioStreamPlayer

@onready var lines_preloader: ResourcePreloader = $LinesPreloader

@rpc("any_peer", "reliable")
func speak(voice_line: String):
	stream = lines_preloader.get_resource(StringName(voice_line))
	play()
