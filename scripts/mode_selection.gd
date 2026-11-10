extends Control

const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"
const DURATION_SELECTION_SCENE := "res://scenes/duration_selection.tscn"

const SELECTED_COLOR := Color("#00E5FF")
const DEFAULT_BORDER_COLOR := Color("#263447")
const CARD_BACKGROUND := Color("#121925")

@onready var classic_card: PanelContainer = $Background/MainLayout/ModeCards/ClassicCard
@onready var precision_card: PanelContainer = $Background/MainLayout/ModeCards/PrecisionCard
@onready var speed_card: PanelContainer = $Background/MainLayout/ModeCards/SpeedCard

@onready var classic_button: Button = $Background/MainLayout/ModeCards/ClassicCard/CardLayout/ClassicButton
@onready var precision_button: Button = $Background/MainLayout/ModeCards/PrecisionCard/CardLayout/PrecisionButton
@onready var speed_button: Button = $Background/MainLayout/ModeCards/SpeedCard/CardLayout/SpeedButton

@onready var back_button: Button = $Background/MainLayout/Footer/BackButton
@onready var continue_button: Button = $Background/MainLayout/Footer/ContinueButton

var selected_mode: String = ""


func _ready() -> void:
	classic_button.pressed.connect(select_classic)
	AudioManager.connect_button_sounds(classic_button)
	precision_button.pressed.connect(select_precision)
	AudioManager.connect_button_sounds(precision_button)
	speed_button.pressed.connect(select_speed)
	AudioManager.connect_button_sounds(speed_button)

	back_button.pressed.connect(return_to_menu)
	AudioManager.connect_button_sounds(back_button)
	continue_button.pressed.connect(continue_to_settings)
	AudioManager.connect_button_sounds(continue_button)
	
	continue_button.disabled = true

	update_card_styles()


func select_classic() -> void:
	select_mode("classic")


func select_precision() -> void:
	select_mode("precision")


func select_speed() -> void:
	select_mode("speed")


func select_mode(mode: String) -> void:
	selected_mode = mode
	TrainingSettings.selected_mode = mode

	update_card_styles()

	continue_button.disabled = false


func update_card_styles() -> void:
	update_card_style(classic_card, selected_mode == "classic")
	update_card_style(precision_card, selected_mode == "precision")
	update_card_style(speed_card, selected_mode == "speed")

	classic_button.text = "SELECTED" if selected_mode == "classic" else "SELECT MODE"
	precision_button.text = "SELECTED" if selected_mode == "precision" else "SELECT MODE"
	speed_button.text = "SELECTED" if selected_mode == "speed" else "SELECT MODE"


func update_card_style(card: PanelContainer, selected: bool) -> void:
	var style := StyleBoxFlat.new()

	style.bg_color = CARD_BACKGROUND
	style.set_border_width_all(2 if selected else 1)
	style.border_color = SELECTED_COLOR if selected else DEFAULT_BORDER_COLOR
	style.set_corner_radius_all(12)

	card.add_theme_stylebox_override("panel", style)


func return_to_menu() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func continue_to_settings() -> void:
	if selected_mode.is_empty():
		return

	get_tree().change_scene_to_file(DURATION_SELECTION_SCENE)
