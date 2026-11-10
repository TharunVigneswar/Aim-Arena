extends Node

const RESULTS_SCENE := "res://scenes/results.tscn"

@onready var timer_label: Label = $TimerLabel

var time_left: float = 0.0
var is_running: bool = false


func _ready() -> void:
	start_timer(TrainingSettings.session_duration)


func _process(delta: float) -> void:
	if not is_running:
		return

	time_left = maxf(time_left - delta, 0.0)
	update_display()

	if time_left == 0.0:
		end_timer()


func start_timer(duration: float) -> void:
	time_left = maxf(duration, 0.0)
	is_running = time_left > 0.0
	update_display()

	if not is_running:
		end_timer()


func end_timer() -> void:
	if not is_running:
		return

	is_running = false
	timer_label.text = "00:00"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	var stats_panel: Control = get_tree().current_scene.get_node("HUD/StatsPanel")

	TrainingSettings.save_results(
		stats_panel.score,
		stats_panel.shots_fired,
		stats_panel.targets_hit,
		stats_panel.missed_shots,
		stats_panel.get_accuracy(),
		stats_panel.best_reaction_time
	)
	
	get_tree().change_scene_to_file(RESULTS_SCENE)

func update_display() -> void:
	var total_seconds := int(ceil(time_left))
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60

	timer_label.text = "%02d:%02d" % [minutes, seconds]
