extends Control
class_name DropZone

# --- Configurações da Zona ---
@export var zone_index : int = 0
var is_occupied : bool = false
var current_syllable : SyllableDraggable = null

func _ready():
	add_to_group("drop_zones")

func get_center_position() -> Vector2:
	return global_position + (size / 2.0)

# Simplificamos a DropZone: Ela apenas recebe peças!
func receive_syllable(syllable: SyllableDraggable):
	is_occupied = true
	current_syllable = syllable
	
	# Cola a sílaba no centro do buraco!
	syllable.global_position = get_center_position() - (syllable.size / 2.0)
	print("Peça RECEBIDA na zona ", zone_index, ": ", syllable.syllable_text)
	
	_notify_game_manager()

func remove_current_syllable():
	is_occupied = false
	current_syllable = null
	_notify_game_manager()

func clear_zone():
	if current_syllable:
		var tween = get_tree().create_tween()
		tween.tween_property(current_syllable, "global_position", current_syllable.original_position, 0.3)
	is_occupied = false
	current_syllable = null
	_notify_game_manager()

func _notify_game_manager():
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		gm.check_word()
