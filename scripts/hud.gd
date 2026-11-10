extends Control

var score: int = 0
var shots_fired: int = 0
var targets_hit: int = 0
var missed_shots: int = 0
var best_reaction_time: float = 0.0

@onready var score_label: Label = $ScoreLabel
@onready var shots_label: Label = $ShotsLabel
@onready var hits_label: Label = $HitsLabel
@onready var accuracy_label: Label = $AccuracyLabel
@onready var misses_label: Label = $MissesLabel


func _ready() -> void:
	update_display()


func register_shot() -> void:
	shots_fired += 1
	update_display()


func register_hit() -> void:
	targets_hit += 1
	score += 100
	update_display()


func register_hit_with_reaction_time(reaction_time: float) -> void:
	targets_hit += 1

	var reaction_score := maxi(
		10,
		roundi(100.0 - maxf(reaction_time, 0.0) * 75.0)
	)

	score += reaction_score

	if best_reaction_time == 0.0 or reaction_time < best_reaction_time:
		best_reaction_time = reaction_time

	update_display()


func register_miss() -> void:
	missed_shots += 1

	var penalty := 5

	match TrainingSettings.selected_mode:
		"precision":
			penalty = 10
		"speed":
			penalty = 15

	score = maxi(score - penalty, 0)
	update_display()


func get_accuracy() -> float:
	if shots_fired == 0:
		return 0.0

	return float(targets_hit) / shots_fired * 100.0


func update_display() -> void:
	score_label.text = "SCORE       %d" % score
	shots_label.text = "SHOTS       %d" % shots_fired
	hits_label.text = "HITS        %d" % targets_hit
	accuracy_label.text = "ACCURACY    %.1f%%" % get_accuracy()
	misses_label.text = "MISSES      %d" % missed_shots
