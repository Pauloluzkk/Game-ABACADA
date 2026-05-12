extends Control

# Vamos usar esse script na raiz da cena (Control)
# Precisaremos pegar o botão invisível e mudaremos o cursor ao passar o mouse.

@onready var play_button = $PlayButton # Caminho relativo na árvore

func _ready():
	# Dá um feedback visual para a criança (opcional)
	# Muda o cursor do mouse para a "mãozinha" quando passar por cima do botão
	play_button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	
	# A conexão do sinal pressed já deve estar feita via editor, não precisa reconectar
	if not play_button.pressed.is_connected(_on_play_button_pressed):
		play_button.pressed.connect(_on_play_button_pressed)


func _on_play_button_pressed():
	print("Botão Invisível 'Jogar' pressionado!")
	# Troca para a cena do jogo
	get_tree().change_scene_to_file("res://Game.tscn")
