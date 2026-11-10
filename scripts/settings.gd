
extends Control

const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var master_slider: HSlider = $Background/MainLayout/SettingsContainer/AudioSection/MasterVolumeRow/MasterVolumeSlider
@onready var music_slider: HSlider = $Background/MainLayout/SettingsContainer/AudioSection/MusicVolumeRow/MusicVolumeSlider
@onready var sfx_slider: HSlider = $Background/MainLayout/SettingsContainer/AudioSection/SFXVolumeRow/SFXVolumeSlider
@onready var back_button: Button = $Background/MainLayout/Footer/BackButton


func _ready() -> void:
	master_slider.value = AudioManager.master_volume
	music_slider.value = AudioManager.music_volume
	sfx_slider.value = AudioManager.sfx_volume

	master_slider.value_changed.connect(AudioManager.set_master_volume)
	music_slider.value_changed.connect(AudioManager.set_music_volume)
	sfx_slider.value_changed.connect(AudioManager.set_sfx_volume)

	back_button.pressed.connect(return_to_menu)
	AudioManager.connect_button_sounds(back_button)


func return_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)
