extends Control
class_name RobotManager

# Emitido quando o robô está completamente montado e a dança termina
signal robot_complete

# Lista de texturas (imagens separadas) das partes do robô.
# O usuário/game designer preenche isso no Godot com arquivos .png
@export var robot_parts_textures : Array[Texture2D] = []

# Referência para o contêiner onde as peças vão ser renderizadas visualmente
@onready var parts_container = $PartsContainer

var current_part_index : int = 0

# --- MÉTODO NOVO: Usar os TextureRects que você já montou e posicionou no Godot ---
func _ready():
	add_to_group("robot_manager")
	# Quando o jogo começa, ele esconde todas as peças que você já posicionou!
	for child in parts_container.get_children():
		child.modulate.a = 0.0 # Transparente / Escondido
		child.scale = Vector2.ZERO

func animate_new_part():
	# Verifica se ainda temos partes escondidas para mostrar
	if current_part_index < parts_container.get_child_count():
		var part_to_show = parts_container.get_child(current_part_index)
		
		# Toca som de montar peça (Opcional)
		print("Mostrando a peça número ", current_part_index)
		
		# Define o centro da própria imagem como eixo pra ela crescer do meio pra fora
		part_to_show.pivot_offset = part_to_show.size / 2.0 
		
		var tween = get_tree().create_tween()
		# Faz ela voltar a ficar opaca
		tween.tween_property(part_to_show, "modulate:a", 1.0, 0.2)
		# Faz ela crescer com o efeito gostoso de elástico!
		tween.parallel().tween_property(part_to_show, "scale", Vector2.ONE, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
		
		current_part_index += 1
		
		# Se mostramos todas as peças que você montou lá, faz a dança do robô completo!
		if current_part_index == parts_container.get_child_count():
			_celebrate_robot_complete()

func _celebrate_robot_complete():
	print("Robô completado!! Iniciar dança!!")
	var tween = get_tree().create_tween().set_loops(3)
	tween.tween_property(parts_container, "rotation_degrees", 5.0, 0.2)
	tween.tween_property(parts_container, "rotation_degrees", -5.0, 0.2)
	tween.tween_property(parts_container, "rotation_degrees", 0.0, 0.2)
	# Aguarda a dança terminar (3 loops × 0.6s cada) e só então sinaliza
	await get_tree().create_timer(3 * 0.6).timeout
	parts_container.rotation_degrees = 0.0
	emit_signal("robot_complete")
