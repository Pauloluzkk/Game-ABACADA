extends VideoStreamPlayer

func _ready():
	# Quando o vídeo da intro terminar, carrega o menu principal do seu jogo
	finished.connect(_on_finished)

func _on_finished():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
