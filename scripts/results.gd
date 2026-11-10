extends Control

const MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var mode_label: Label = $CenterContainer/ResultsLayout/ModeLabel
@onready var score_label: Label = $CenterContainer/ResultsLayout/ScoreLabel
@onready var accuracy_label: Label = $CenterContainer/ResultsLayout/AccuracyLabel
@onready var hits_label: Label = $CenterContainer/ResultsLayout/HitsLabel
@onready var misses_label: Label = $CenterContainer/ResultsLayout/MissesLabel
@onready var shots_label: Label = $CenterContainer/ResultsLayout/ShotsLabel
@onready var best_reaction_label: Label = $CenterContainer/ResultsLayout/BestReactionLabel

@onready var play_again_button: Button = $CenterContainer/ResultsLayout/PlayAgainButton
@onready var main_menu_button: Button = $CenterContainer/ResultsLayout/MainMenuButton


func _ready() -> void:
	display_results()

	play_again_button.pressed.connect(return_to_menu)
	AudioManager.connect_button_sounds(play_again_button)
	main_menu_button.pressed.connect(return_to_menu)
	AudioManager.connect_button_sounds(main_menu_button)


func display_results() -> void:
	mode_label.text = "MODE: %s" % TrainingSettings.final_mode.to_upper()
	score_label.text = "SCORE: %d" % TrainingSettings.final_score
	accuracy_label.text = "ACCURACY: %.1f%%" % TrainingSettings.final_accuracy
	hits_label.text = "TARGETS HIT: %d" % TrainingSettings.final_hits
	misses_label.text = "MISSES: %d" % TrainingSettings.final_misses
	shots_label.text = "SHOTS FIRED: %d" % TrainingSettings.final_shots

	if TrainingSettings.final_mode == "speed":
		if TrainingSettings.final_best_reaction_time > 0.0:
			best_reaction_label.text = "BEST REACTION: %.3f SEC" % TrainingSettings.final_best_reaction_time
		else:
			best_reaction_label.text = "BEST REACTION: NO HITS"
	else:
		best_reaction_label.text = "BEST REACTION: --"


func return_to_menu() -> void:
	TrainingSettings.reset_results()
	get_tree().change_scene_to_file(MENU_SCENE)
