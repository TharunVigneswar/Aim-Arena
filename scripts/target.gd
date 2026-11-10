extends StaticBody3D

@export_category("Target")
@export var max_health: float = 1.0

@export_category("Animation")
@export var hover_height: float = 0.12
@export var hover_speed: float = 1.8

var current_health: float = 0.0
var animation_time: float = 0.0
var spawn_time: int = 0

var body_material: StandardMaterial3D

@onready var visuals: Node3D = $Visuals


func _ready() -> void:
	current_health = max_health
	spawn_time = Time.get_ticks_msec()

	var body := visuals.get_node_or_null("MainShell") as MeshInstance3D

	if body:
		body_material = body.get_active_material(0) as StandardMaterial3D


func _process(delta: float) -> void:
	animation_time += delta

	visuals.position.y = sin(animation_time * hover_speed) * hover_height

	var core := visuals.get_node_or_null("Core") as MeshInstance3D

	if core:
		var pulse := 1.0 + sin(animation_time * 3.0) * 0.04
		core.scale = Vector3.ONE * pulse


func get_reaction_time() -> float:
	return float(Time.get_ticks_msec() - spawn_time) / 1000.0


func take_damage(amount: float) -> void:
	current_health -= amount
	current_health = maxf(current_health, 0.0)

	if current_health <= 0.0:
		destroy_target()
	else:
		hit_feedback()


func hit_feedback() -> void:
	if body_material == null:
		return

	var original_color: Color = body_material.albedo_color

	body_material.albedo_color = Color.WHITE

	var tween := create_tween()

	tween.tween_property(
		body_material,
		"albedo_color",
		original_color,
		0.12
	)


func destroy_target() -> void:
	queue_free()
