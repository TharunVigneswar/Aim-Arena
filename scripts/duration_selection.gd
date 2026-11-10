extends Control

const GAME_SCENE := "res://scenes/main.tscn"
const MODE_SELECTION_SCENE := "res://scenes/mode_selection.tscn"
const SELECTED_COLOR := Color("#00E5FF")
const DURATIONS: Array[float] = [30.0, 60.0, 90.0]

@onready var duration_buttons: Array[Button] = [
	$"Background/CenterContainer/MenuLayout/DurationButtons/30SecondsButton",
	$"Background/CenterContainer/MenuLayout/DurationButtons/60SecondsButton",
	$"Background/CenterContainer/MenuLayout/DurationButtons/90SecondsButton"
]

@onready var start_button: Button = $Background/CenterContainer/MenuLayout/StartButton
@onready var back_button: Button = $Background/CenterContainer/MenuLayout/BackButton

var selected_duration: float = 60.0



func _ready() -> void:
	for index in range(duration_buttons.size()):
		var button := duration_buttons[index]
		button.pressed.connect(select_duration.bind(DURATIONS[index]))
		AudioManager.connect_button_sounds(button)

	start_button.pressed.connect(start_training)
	AudioManager.connect_button_sounds(start_button)

	back_button.pressed.connect(return_to_modes)
	AudioManager.connect_button_sounds(back_button)

	select_duration(selected_duration)

func select_duration(duration: float) -> void:
	selected_duration = duration

	for index in range(duration_buttons.size()):
		var button := duration_buttons[index]
		button.modulate = SELECTED_COLOR if DURATIONS[index] == duration else Color.WHITE


func start_training() -> void:
	TrainingSettings.session_duration = selected_duration
	get_tree().change_scene_to_file(GAME_SCENE)


func return_to_modes() -> void:
	get_tree().change_scene_to_file(MODE_SELECTION_SCENE)
