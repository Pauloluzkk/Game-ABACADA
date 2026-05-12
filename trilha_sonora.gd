extends AudioStreamPlayer

func _ready() -> void:
	# Carrega a trilha sonora
	stream = load("res://assets/Clockwork_Critters.mp3")
	
	# Define o canal de áudio (o menu lateral controla o Master)
	bus = "Master"
	
	finished.connect(play)
	
	# Inicia a música
	play()
