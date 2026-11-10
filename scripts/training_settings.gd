extends Node

var session_duration: float = 60.0
var selected_mode: String = ""

var final_score: int = 0
var final_shots: int = 0
var final_hits: int = 0
var final_misses: int = 0
var final_accuracy: float = 0.0
var final_best_reaction_time: float = 0.0
var final_mode: String = ""


func save_results(
	score: int,
	shots: int,
	hits: int,
	misses: int,
	accuracy: float,
	best_reaction: float
) -> void:
	final_score = score
	final_shots = shots
	final_hits = hits
	final_misses = misses
	final_accuracy = accuracy
	final_best_reaction_time = best_reaction
	final_mode = selected_mode


func reset_results() -> void:
	final_score = 0
	final_shots = 0
	final_hits = 0
	final_misses = 0
	final_accuracy = 0.0
	final_best_reaction_time = 0.0
	final_mode = ""
