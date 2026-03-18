extends Node
class_name GameManager

# Lista de palavras que a criança precisará formar, em ordem!
@export var levels : Array[Array] = [
	["BO", "NE", "CA"],
	["DA", "DO"],
	["SA", "PO"],
	["CA", "SA"] # Quarta palavra para a 4ª peça do robô!
]

# Banco de sílabas aleatórias para confundir a criança
var distraction_syllables : Array[String] = ["TE", "LA", "MI", "VU", "RU", "PA", "JO", "GE", "FI", "CO"]

var current_level_index : int = 0
var target_word : Array = []

func _ready():
	add_to_group("game_manager")
	# Começa o primeiro nível!
	load_level(current_level_index)

func load_level(level_index : int):
	if level_index >= levels.size():
		print("VOCÊ VENCEU O JOGO INTEIRO!")
		return
		
	target_word = levels[level_index]
	print("Carregando palavra: ", target_word)
	
	# 1. Configura a quantidade visível de "Buracos" (DropZones)
	var drop_zones = get_tree().get_nodes_in_group("drop_zones")
	for zone in drop_zones:
		# Se a palavra for 'DADO' (tamanho 2), esconde a zona Roxa (index 2)
		if zone.zone_index < target_word.size():
			zone.show()
		else:
			zone.hide()
			
	# 2. Prepara o conjunto de Sílabas que vão para a mesa (Certas + Erradas)
	var syllables_for_this_round = []
	syllables_for_this_round.append_array(target_word) # Adiciona as certas
	
	# Adiciona 2 distrações aleatórias
	distraction_syllables.shuffle()
	syllables_for_this_round.append(distraction_syllables[0])
	syllables_for_this_round.append(distraction_syllables[1])
	
	# Embaralha todas juntas para a criança ter que procurar
	syllables_for_this_round.shuffle()
	
	# 3. Atualiza os bloquinhos arrastáveis na tela
	# Nota: Precisamos ter pelo menos 5 instâncias de Syllable.tscn criadas na cena!
	var draggables = get_tree().get_nodes_in_group("draggables")
	
	# Passa por todas as sílabas que temos na cena
	for i in range(draggables.size()):
		var draggable = draggables[i]
		if i < syllables_for_this_round.size():
			# Pega uma sílaba embaralhada
			draggable.show()
			draggable.global_position = draggable.original_position # Garante que volte pra prateleira
			draggable.syllable_text = syllables_for_this_round[i]
			# Atualiza o Label visualmente
			if draggable.has_node("Label"):
				draggable.get_node("Label").text = syllables_for_this_round[i]
		else:
			# Esconde sílabas que sobrarem da cena
			draggable.hide()

func check_word():
	var drop_zones = get_tree().get_nodes_in_group("drop_zones")
	if drop_zones.size() == 0:
		return
		
	var word_formed = true
	
	for zone in drop_zones:
		# Ignora zonas que estão escondidas pra essa palavra menor
		if not zone.visible:
			continue
			
		var expected_syllable = ""
		if zone.zone_index < target_word.size():
			expected_syllable = target_word[zone.zone_index]
		
		# Verifica preenchimento correto
		if not zone.is_occupied or zone.current_syllable == null:
			word_formed = false
			break
			
		if zone.current_syllable.syllable_text != expected_syllable:
			word_formed = false
			break
			
	if word_formed:
		_on_word_completed()

func _on_word_completed():
	print("PARABÉNS! Palavra ", target_word, " formada corretamente!")
	
	for node in get_tree().get_nodes_in_group("draggables"):
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var robot_m = get_tree().get_first_node_in_group("robot_manager")
	if robot_m:
		robot_m.animate_new_part()
		
	await get_tree().create_timer(2.0).timeout
	
	for drop_zone in get_tree().get_nodes_in_group("drop_zones"):
		drop_zone.clear_zone()
		
	for node in get_tree().get_nodes_in_group("draggables"):
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE # Vamos usar PASS no _ready da sílaba mas tem que resetar aqui depois do clear
		node.mouse_filter = Control.MOUSE_FILTER_PASS
		
	# Avança para a próxima palavra
	current_level_index += 1
	load_level(current_level_index)
