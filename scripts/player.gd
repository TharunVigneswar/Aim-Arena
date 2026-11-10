extends CharacterBody3D

@export_category("Movement")
@export var move_speed: float = 7.0
@export var jump_velocity: float = 4.5

@export_category("Mouse")
@export var mouse_sensitivity: float = 0.002
@export var min_look_angle: float = -85.0
@export var max_look_angle: float = 85.0

@onready var head: Node3D = $Head

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clampf(
			head.rotation.x,
			deg_to_rad(min_look_angle),
			deg_to_rad(max_look_angle)
		)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_backward"
	)

	var direction := transform.basis * Vector3(
		input_direction.x,
		0.0,
		input_direction.y
	)

	direction = direction.normalized()

	if direction.length_squared() > 0.0:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		var deceleration := move_speed * 8.0 * delta
		velocity.x = move_toward(velocity.x, 0.0, deceleration)
		velocity.z = move_toward(velocity.z, 0.0, deceleration)

	move_and_slide()
