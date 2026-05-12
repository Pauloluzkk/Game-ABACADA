extends Node
class_name GameManager

# -------------------------------------------------------
# Referências para nós da cena
# -------------------------------------------------------
@onready var imagem_palavra : TextureRect = $ImagemPalavra

# -------------------------------------------------------
# Estado Interno
# -------------------------------------------------------
var current_level_index : int = 0
var target_word : Array = []
var _ready_to_play : bool = false
var _game_over : bool = false

# Número de rodadas = número de peças do robô na cena
var _total_rounds : int = 0

func _ready():
	add_to_group("game_manager")
	
	# Conecta ao sinal do RobotManager para saber quando o robô completou
	var robot_m = get_tree().get_first_node_in_group("robot_manager")
	if robot_m:
		robot_m.robot_complete.connect(_on_robot_complete)
		_total_rounds = robot_m.parts_container.get_child_count()
		print("🤖 Total de peças do robô: ", _total_rounds, " → Total de rodadas.")
	
	# Aguarda os dados da API
	if Global.array_palavras.size() > 0:
		_on_dados_prontos()
	else:
		Global.dados_prontos.connect(_on_dados_prontos)
		print("⏳ Aguardando dados da API...")

func _on_dados_prontos():
	print("▶️ Dados recebidos! Total de palavras: ", Global.array_palavras.size())
	_ready_to_play = true
	Global.embaralhar()
	load_level(0)

# -------------------------------------------------------
# Extrai apenas as letras de um complemento com underscores
# Ex: "_ _TO" → "TO" | "_MA" → "MA"
# -------------------------------------------------------
func _parse_complemento(raw : String) -> String:
	var result = ""
	for c in raw:
		if c != "_" and c != " ":
			result += c
	return result

# -------------------------------------------------------
# Carrega um nível a partir dos dados do Global
# -------------------------------------------------------
func load_level(level_index : int):
	if _game_over:
		return
	
	current_level_index = level_index
	
	# Para após o número de rodadas igual às peças do robô
	if level_index >= _total_rounds or level_index >= Global.array_palavras.size():
		print("🏆 Todas as rodadas concluídas! Aguardando dança do robô...")
		return
	
	var entry = Global.array_palavras[level_index]
	
	# Limpa e extrai as sílabas da nova estrutura da API
	target_word.clear()
	for s_dict in entry.silabas:
		var silaba_limpa = _parse_complemento(s_dict.silaba)
		target_word.append(silaba_limpa)
		
	print("📖 Palavra: ", entry.palavra, " → sílabas: ", target_word)
	
	# --- Atualiza imagem de associação ---
	if imagem_palavra and entry.imagens.size() > 0:
		imagem_palavra.texture = entry.imagens[0]
	
	# --- Configura DropZones visíveis ---
	var drop_zones = get_tree().get_nodes_in_group("drop_zones")
	for zone in drop_zones:
		if zone.zone_index < target_word.size():
			zone.show()
		else:
			zone.hide()
	
	# --- Monta sílabas: certas + distrações ---
	var syllables_for_round : Array = []
	syllables_for_round.append_array(target_word)
	
	# Pega sílabas de distração de outros itens
	var distraction_pool : Array = []
	for i in range(Global.array_palavras.size()):
		if i == level_index:
			continue
		for s_dict in Global.array_palavras[i].silabas:
			var silaba_limpa = _parse_complemento(s_dict.silaba)
			if silaba_limpa.length() > 0:
				distraction_pool.append(silaba_limpa)
	
	distraction_pool.shuffle()
	for i in range(min(2, distraction_pool.size())):
		syllables_for_round.append(distraction_pool[i])
	
	syllables_for_round.shuffle()
	
	# --- Distribui para os arrastáveis ---
	var draggables = get_tree().get_nodes_in_group("draggables")
	for i in range(draggables.size()):
		var draggable = draggables[i]
		if i < syllables_for_round.size():
			draggable.show()
			draggable.global_position = draggable.original_position
			draggable.syllable_text = syllables_for_round[i]
			if draggable.has_node("Label"):
				draggable.get_node("Label").text = syllables_for_round[i]
		else:
			draggable.hide()

# -------------------------------------------------------
# Verifica se a palavra foi formada corretamente
# -------------------------------------------------------
func check_word():
	if not _ready_to_play or _game_over:
		return
		
	var drop_zones = get_tree().get_nodes_in_group("drop_zones")
	if drop_zones.size() == 0:
		return

	var word_formed = true

	for zone in drop_zones:
		if not zone.visible:
			continue
		if not zone.is_occupied or zone.current_syllable == null:
			word_formed = false
			break
		var expected = target_word[zone.zone_index] if zone.zone_index < target_word.size() else ""
		if zone.current_syllable.syllable_text != expected:
			word_formed = false
			break

	if word_formed:
		_on_word_completed()

# -------------------------------------------------------
# Trata a vitória da rodada
# -------------------------------------------------------
func _on_word_completed():
	print("🎉 PARABÉNS! Palavra '", target_word, "' formada corretamente!")
	_ready_to_play = false # Pausa novos check_word durante animação
	
	for node in get_tree().get_nodes_in_group("draggables"):
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var robot_m = get_tree().get_first_node_in_group("robot_manager")
	if robot_m:
		robot_m.animate_new_part()
	
	await get_tree().create_timer(2.0).timeout
	
	for drop_zone in get_tree().get_nodes_in_group("drop_zones"):
		drop_zone.clear_zone()
	
	for node in get_tree().get_nodes_in_group("draggables"):
		node.mouse_filter = Control.MOUSE_FILTER_PASS
	
	# Só avança se ainda houver rodadas (robô incompleto)
	if not _game_over:
		_ready_to_play = true
		load_level(current_level_index + 1)

# -------------------------------------------------------
# Chamado pelo RobotManager quando o robô está 100% completo
# -------------------------------------------------------
func _on_robot_complete():
	_game_over = true
	_ready_to_play = false
	print("🏆 JOGO COMPLETO! Robô montado e dançando!")
	
	# Congela tudo
	for node in get_tree().get_nodes_in_group("draggables"):
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Aqui você pode trocar para uma tela de vitória futuramente:
	# get_tree().change_scene_to_file("res://VictoryScreen.tscn")
