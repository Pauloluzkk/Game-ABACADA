extends CanvasLayer

var master_vol = AudioServer.get_bus_index("Master")

@onready var v_slider = $VSlider
@onready var volume_on = $button_volume/Volume_ON
@onready var volume_off = $button_volume/Volume_OFF
@onready var normal_door = $button_sair/Normal
@onready var voltar_arrow = $button_sair/Voltar

func _ready():
	# Conecta os sinais de clique e arraste
	$button_volume.pressed.connect(_on_button_volume_pressed)
	$button_sair.pressed.connect(_on_button_sair_pressed)
	v_slider.value_changed.connect(_on_v_slider_value_changed)
	
	_update_ui_state()
	
	# Restaura o volume salvo
	if "volume" in Global:
		v_slider.value = Global.volume

func _process(_delta):
	# Opcional: Atualiza o ícone caso a cena mude e estejamos usando AutoLoad
	_update_ui_state()

func _update_ui_state():
	# Verifica em qual cena estamos para mostrar o ícone de Porta (sair) ou Seta (voltar)
	# Previne erro no AutoLoad caso a cena ainda esteja carregando
	if get_tree().current_scene == null:
		return
		
	var current_scene_name = get_tree().current_scene.name
	if current_scene_name == "MainMenu":
		normal_door.visible = true
		voltar_arrow.visible = false
	else:
		normal_door.visible = false
		voltar_arrow.visible = true

func _on_v_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(master_vol, value)
	if "volume" in Global:
		Global.volume = value
	
	if value <= -20.0:
		AudioServer.set_bus_mute(master_vol, true)
		volume_off.visible = true
		volume_on.visible = false
		if "audio_enabled" in Global:
			Global.audio_enabled = false
	else:
		AudioServer.set_bus_mute(master_vol, false)
		volume_off.visible = false
		volume_on.visible = true
		if "audio_enabled" in Global:
			Global.audio_enabled = true

func _on_button_volume_pressed() -> void:
	if Global.audio_enabled:
		v_slider.value = -20.0
	else:
		# Se estava mudo, restaura para 0 (que é um volume bom no slider)
		v_slider.value = 0.0

func _on_button_sair_pressed() -> void:
	if get_tree().current_scene == null:
		return
		
	var current_scene_name = get_tree().current_scene.name
	if current_scene_name == "MainMenu":
		# Pode colocar aqui a chamada postData no futuro antes de sair
		get_tree().quit()
	else:
		# Volta para o menu inicial do jogo
		get_tree().change_scene_to_file("res://MainMenu.tscn")
