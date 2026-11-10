
extends Control

const MODE_SELECTION_SCENE := "res://scenes/mode_selection.tscn"
const SETTINGS_SCENE := "res://scenes/settings.tscn"

@onready var play_button: Button = $Background/CenterContainer/MenuLayout/StartButton
@onready var settings_button: Button = $Background/CenterContainer/MenuLayout/SettingsButton


func _ready() -> void:
	play_button.pressed.connect(open_mode_selection)
	settings_button.pressed.connect(open_settings)

	AudioManager.connect_button_sounds(play_button)
	AudioManager.connect_button_sounds(settings_button)

	AudioManager.play_music("res://audio/music/menu_music.mp3")


func open_mode_selection() -> void:
	get_tree().change_scene_to_file(MODE_SELECTION_SCENE)


func open_settings() -> void:
	get_tree().change_scene_to_file(SETTINGS_SCENE)
