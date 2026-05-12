extends Control

# -------------------------------------------------------
# Menu lateral padrão — presente em todos os jogos
# Controles: Volume, Liga/Desliga Som, Sair
# -------------------------------------------------------

# O volume é salvo globalmente via Global para persistir entre cenas
var _audio_enabled : bool = true

@onready var volume_slider   : HSlider = $Panel/VBox/VolumeSlider
@onready var btn_sound       : TextureButton = $Panel/VBox/BtnSound
@onready var btn_exit        : TextureButton = $Panel/VBox/BtnExit
@onready var icon_sound_on   : Texture2D = preload("res://assets/ui/icon_sound_on.png")
@onready var icon_sound_off  : Texture2D = preload("res://assets/ui/icon_sound_off.png")

func _ready():
	# Restaura o estado de som do Global (se existir)
	if "volume" in Global:
		volume_slider.value = Global.volume if "volume" in Global else 1.0
		_audio_enabled      = Global.audio_enabled if "audio_enabled" in Global else true
	
	_apply_volume(volume_slider.value)
	_update_sound_icon()
	
	# Conecta sinais
	volume_slider.value_changed.connect(_on_volume_changed)
	btn_sound.pressed.connect(_on_btn_sound_pressed)
	btn_exit.pressed.connect(_on_btn_exit_pressed)

# -------------------------------------------------------
# Volume
# -------------------------------------------------------
func _on_volume_changed(value: float):
	_apply_volume(value)
	# Persiste no Global para outras cenas
	if "volume" in Global:
		Global.volume = value

func _apply_volume(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),
		linear_to_db(value))

# -------------------------------------------------------
# Liga / Desliga Som
# -------------------------------------------------------
func _on_btn_sound_pressed():
	_audio_enabled = !_audio_enabled
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), !_audio_enabled)
	_update_sound_icon()
	if "audio_enabled" in Global:
		Global.audio_enabled = _audio_enabled

func _update_sound_icon():
	if _audio_enabled:
		btn_sound.texture_normal = icon_sound_on
	else:
		btn_sound.texture_normal = icon_sound_off

# -------------------------------------------------------
# Sair — volta para o MainMenu
# -------------------------------------------------------
func _on_btn_exit_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
