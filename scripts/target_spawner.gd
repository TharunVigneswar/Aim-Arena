extends Node3D

@export var target_scene: PackedScene

@export_category("Classic Mode")
@export var classic_target_count: int = 6
@export var classic_respawn_delay: float = 0.8

@export_category("Precision Mode")
@export var precision_target_count: int = 1
@export var precision_respawn_delay: float = 0.8

@export_category("Speed Mode")
@export var speed_target_count: int = 1
@export var speed_min_respawn_delay: float = 0.5
@export var speed_max_respawn_delay: float = 1.0

@export_category("Spawn Area")
@export var min_x: float = -8.0
@export var max_x: float = 8.0
@export var min_y: float = 1.9
@export var max_y: float = 5.1
@export var target_z: float = -13.0

@export_category("Target Spacing")
@export var min_distance: float = 2.3
@export var spawn_attempts: int = 100

var max_targets: int = 6
var respawn_delay: float = 0.8

var active_targets: int = 0
var occupied_positions: Dictionary = {}


func _ready() -> void:
	randomize()
	configure_mode()

	for i in range(max_targets):
		spawn_target()


func configure_mode() -> void:
	match TrainingSettings.selected_mode:
		"classic":
			max_targets = classic_target_count
			respawn_delay = classic_respawn_delay

		"precision":
			max_targets = precision_target_count
			respawn_delay = precision_respawn_delay

		"speed":
			max_targets = speed_target_count
			respawn_delay = 0.0

		_:
			max_targets = classic_target_count
			respawn_delay = classic_respawn_delay


func spawn_target() -> void:
	if not is_inside_tree() or target_scene == null:
		return

	if active_targets >= max_targets:
		return

	var spawn_position := find_spawn_position()

	if spawn_position == Vector3.INF:
		get_tree().create_timer(0.25).timeout.connect(
			spawn_target,
			CONNECT_ONE_SHOT
		)
		return

	var target := target_scene.instantiate() as Node3D

	if target == null:
		return

	add_child(target)
	target.global_position = spawn_position

	active_targets += 1

	var target_id := target.get_instance_id()
	occupied_positions[target_id] = spawn_position

	target.tree_exited.connect(_on_target_destroyed.bind(target_id))


func find_spawn_position() -> Vector3:
	for attempt in range(spawn_attempts):
		var candidate := Vector3(
			randf_range(min_x, max_x),
			randf_range(min_y, max_y),
			target_z
		)

		var valid_position := true

		for occupied_position in occupied_positions.values():
			if candidate.distance_to(occupied_position) < min_distance:
				valid_position = false
				break

		if valid_position:
			return candidate

	return Vector3.INF


func _on_target_destroyed(target_id: int) -> void:
	occupied_positions.erase(target_id)

	if not is_inside_tree():
		return

	active_targets = maxi(active_targets - 1, 0)

	var delay := respawn_delay

	if TrainingSettings.selected_mode == "speed":
		delay = randf_range(
			speed_min_respawn_delay,
			speed_max_respawn_delay
		)

	await get_tree().create_timer(delay).timeout

	if is_inside_tree():
		spawn_target()
