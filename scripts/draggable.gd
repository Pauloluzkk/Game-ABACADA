extends Control
class_name SyllableDraggable

# --- Variáveis Exportadas para Configuração no Editor ---
@export var syllable_text : String = "BA" # O texto da sílaba
@export var original_position : Vector2 # Onde a peça volta se não for solta no lugar certo

# --- Referências ---
@onready var label = $Label # Presume que haverá um nó filho Label para mostrar o texto

# --- Controles de Estado ---
var is_dragging : bool = false
var drag_offset : Vector2 = Vector2.ZERO
var current_drop_zone : Node = null # Armazena se estamos sobre uma zona de soltura válida

# --- Áudio ---
var audio_stream : AudioStream = null
var audio_player : AudioStreamPlayer = AudioStreamPlayer.new()


func _ready():
	# Configura a posição inicial (na prateleira)
	original_position = global_position
	# Define o texto do Label
	if label:
		label.text = syllable_text
	
	# Garante que o Control não bloqueie cliques em áreas vazias dele próprio
	mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Garante que o Panel e o Label não engulam o clique do mouse!
	for child in get_children():
		if child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Configura o tocador de áudio
	add_child(audio_player)

# Função para o GameManager injetar os dados da sílaba
func set_syllable_data(text: String, audio: AudioStream):
	syllable_text = text
	if label:
		label.text = text
	audio_stream = audio


# O Godot chama esta função automaticamente para eventos de Input neste controle
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				# INICIA O ARRASTE E TOCA O SOM
				if audio_stream:
					audio_player.stream = audio_stream
					audio_player.play()
					
				is_dragging = true
				
				# Se a criança pegou a peça de novo e ela estava numa zona de drop, libera a zona
				if current_drop_zone and current_drop_zone.current_syllable == self:
					current_drop_zone.remove_current_syllable()
					current_drop_zone = null
					
				# Calcula a diferença entre o clique e a origem da textura para arrastar macio
				drag_offset = global_position - get_global_mouse_position()
				# Move a peça para a frente das outras Z-Index
				z_index = 100
			else:
				# SOLTA A PEÇA
				is_dragging = false
				z_index = 0
				_handle_drop()

func _process(_delta):
	# Se estiver arrastando, segue o mouse + offset
	if is_dragging:
		global_position = get_global_mouse_position() + drag_offset

func _handle_drop():
	# Busca todas as dropzones válidas no jogo
	var all_drop_zones = get_tree().get_nodes_in_group("drop_zones")
	var dropped_on_valid_zone = false
	
	for zone in all_drop_zones:
		if _is_over_drop_zone(zone) and not zone.is_occupied:
			# Registra fisicamente na DropZone matemática
			current_drop_zone = zone
			zone.receive_syllable(self)
			dropped_on_valid_zone = true
			break # Cola na primeira que detectar
	
	if not dropped_on_valid_zone:
		# Não soltou em nenhuma zona válida (ou tava cheia), volta pra prateleira!
		current_drop_zone = null
		var tween = get_tree().create_tween()
		tween.tween_property(self, "global_position", original_position, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

# NOVA FUNÇÃO: Checa matematicamente se a peça solta cai DENTRO do quadrado geométrico da zona
func _is_over_drop_zone(zone: Node) -> bool:
	# Pega o Retângulo (Global) da Zona de Alvo (Amarela, Verde...)
	var zone_rect = Rect2(zone.global_position, zone.size)
	# Pega o próprio meio (Centro da sílaba)
	var my_center = global_position + (size / 2.0)
	
	# A sílaba colou no buraco SE o centro dela estiver caindo dentro do retângulo do buraco!
	return zone_rect.has_point(my_center)
