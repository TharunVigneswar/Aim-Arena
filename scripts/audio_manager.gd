
extends Node

var music_player: AudioStreamPlayer
var current_track: String = ""

var shoot_sound: AudioStream
var hit_sound: AudioStream
var miss_sound: AudioStream
var click_sound: AudioStream

var master_volume: float = 75.0
var music_volume: float = 60.0
var sfx_volume: float = 80.0

const SETTINGS_PATH := "user://settings.cfg"


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)

	shoot_sound = load("res://audio/sfx/shoot.ogg")
	hit_sound = load("res://audio/sfx/hit.ogg")
	miss_sound = load("res://audio/sfx/miss.ogg")
	click_sound = load("res://audio/sfx/button_click.ogg")

	load_settings()
	apply_audio_settings()


func load_settings() -> void:
	var config := ConfigFile.new()
	var error := config.load(SETTINGS_PATH)

	if error == OK:
		master_volume = config.get_value("audio", "master_volume", 75.0)
		music_volume = config.get_value("audio", "music_volume", 60.0)
		sfx_volume = config.get_value("audio", "sfx_volume", 80.0)


func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)

	config.save(SETTINGS_PATH)


func apply_audio_settings() -> void:
	var master_index := AudioServer.get_bus_index("Master")
	var music_index := AudioServer.get_bus_index("Music")
	var sfx_index := AudioServer.get_bus_index("SFX")

	if master_index >= 0:
		AudioServer.set_bus_volume_linear(master_index, master_volume / 100.0)

	if music_index >= 0:
		AudioServer.set_bus_volume_linear(music_index, music_volume / 100.0)

	if sfx_index >= 0:
		AudioServer.set_bus_volume_linear(sfx_index, sfx_volume / 100.0)


func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 100.0)
	apply_audio_settings()
	save_settings()


func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 100.0)
	apply_audio_settings()
	save_settings()

	var music_index := AudioServer.get_bus_index("Music")

	print("Music slider: ", music_volume)
	print("Music bus index: ", music_index)
	print("Music bus volume: ", AudioServer.get_bus_volume_linear(music_index))
	print("Music player bus: ", music_player.bus)
	print("Music playing: ", music_player.playing)


func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 100.0)
	apply_audio_settings()
	save_settings()


func play_music(track_path: String) -> void:
	if current_track == track_path and music_player.playing:
		return

	var track := load(track_path) as AudioStream

	if track == null:
		return

	current_track = track_path
	music_player.stream = track
	music_player.play()


func stop_music() -> void:
	music_player.stop()
	current_track = ""


func play_sfx(sound: AudioStream, volume_db: float = 0.0) -> void:
	if sound == null:
		return

	var player := AudioStreamPlayer.new()
	player.stream = sound
	player.bus = "SFX"
	player.volume_db = volume_db
	add_child(player)

	player.finished.connect(player.queue_free)
	player.play()


func play_shoot() -> void:
	play_sfx(shoot_sound, -3.0)


func play_hit() -> void:
	play_sfx(hit_sound, -2.0)


func play_miss() -> void:
	play_sfx(miss_sound, -4.0)


func play_click() -> void:
	play_sfx(click_sound, -3.0)


func connect_button_sounds(button: Button) -> void:
	button.pressed.connect(play_click)
