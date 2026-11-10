extends Camera3D

@export_category("Shooting")
@export var damage: float = 1.0
@export var fire_rate: float = 0.12
@export var max_range: float = 100.0

@export_category("Weapon Recoil")
@export var kick_distance: float = 0.20
@export var kick_angle: float = 9.0
@export var kick_sideways: float = 0.02
@export var recoil_stiffness: float = 65.0
@export var recoil_damping: float = 13.0

@export_category("Projectile")
@export var bullet_speed: float = 45.0
@export var bullet_length: float = 0.18
@export var bullet_radius: float = 0.025

@export_category("Impact Particles")
@export var particle_amount: int = 20
@export var particle_lifetime: float = 0.45
@export var particle_speed_min: float = 2.0
@export var particle_speed_max: float = 5.0

@onready var aim_ray: RayCast3D = $AimRay
@onready var weapon: Node3D = $Weapon
@onready var muzzle: Node3D = $Weapon/Muzzle
@onready var muzzle_flash: MeshInstance3D = $Weapon/MuzzleFlash
@onready var stats_panel = get_tree().current_scene.get_node("HUD/StatsPanel")

var can_shoot: bool = true
var original_position: Vector3
var original_rotation: Vector3
var recoil_position := Vector3.ZERO
var recoil_velocity := Vector3.ZERO


func _ready() -> void:
	aim_ray.enabled = true
	aim_ray.target_position = Vector3(0.0, 0.0, -max_range)

	original_position = weapon.position
	original_rotation = weapon.rotation

	muzzle_flash.visible = false


func _process(delta: float) -> void:
	var acceleration := -recoil_position * recoil_stiffness

	recoil_velocity += acceleration * delta
	recoil_velocity *= exp(-recoil_damping * delta)
	recoil_position += recoil_velocity * delta

	weapon.position = original_position + recoil_position

	var rotation_factor := recoil_position.z / maxf(kick_distance, 0.001)

	weapon.rotation = original_rotation + Vector3(
		deg_to_rad(-rotation_factor * kick_angle),
		0.0,
		deg_to_rad(-recoil_position.x * 2.0 / maxf(kick_sideways, 0.001))
	)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		shoot()


func shoot() -> void:
	if not can_shoot:
		return

	can_shoot = false
	stats_panel.register_shot()
	AudioManager.play_shoot()

	recoil_velocity += Vector3(
		kick_sideways,
		-kick_distance * 0.25,
		kick_distance
	) * 12.0

	muzzle_flash.visible = true

	aim_ray.force_raycast_update()

	var bullet_start := muzzle.global_position
	var bullet_end: Vector3
	var hit_object: Object = null
	var impact_color := Color("#FF3030")

	if aim_ray.is_colliding():
		bullet_end = aim_ray.get_collision_point()
		hit_object = aim_ray.get_collider()

		if hit_object.has_method("take_damage"):
			impact_color = Color("#00E5FF")
	else:
		bullet_end = aim_ray.to_global(aim_ray.target_position)

	create_bullet(bullet_start, bullet_end, impact_color, hit_object)

	await get_tree().create_timer(0.06).timeout

	if is_instance_valid(muzzle_flash):
		muzzle_flash.visible = false

	await get_tree().create_timer(maxf(fire_rate, 0.0)).timeout

	can_shoot = true


func create_bullet(
	start: Vector3,
	finish: Vector3,
	impact_color: Color,
	hit_object: Object
) -> void:
	var bullet := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()

	capsule.radius = bullet_radius
	capsule.height = maxf(bullet_length, bullet_radius * 2.0)

	bullet.mesh = capsule

	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#00E5FF")
	material.emission_enabled = true
	material.emission = Color("#00E5FF")
	material.emission_energy_multiplier = 4.0
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	bullet.material_override = material

	get_tree().current_scene.add_child(bullet)

	bullet.global_position = start
	bullet.look_at(finish, Vector3.UP)
	bullet.rotate_object_local(Vector3.RIGHT, deg_to_rad(90.0))

	var distance := start.distance_to(finish)
	var travel_time := maxf(distance / maxf(bullet_speed, 0.001), 0.08)

	var tween := create_tween()

	tween.tween_property(
		bullet,
		"global_position",
		finish,
		travel_time
	).set_trans(Tween.TRANS_LINEAR)

	tween.tween_callback(
		_on_projectile_impact.bind(finish, impact_color, hit_object, bullet)
	)


func _on_projectile_impact(
	position: Vector3,
	impact_color: Color,
	hit_object: Object,
	bullet: MeshInstance3D
) -> void:
	if is_instance_valid(hit_object) and hit_object.has_method("take_damage"):
		var reaction_time := 0.0

		if TrainingSettings.selected_mode == "speed":
			reaction_time = hit_object.get_reaction_time()
			stats_panel.register_hit_with_reaction_time(reaction_time)
		else:
			stats_panel.register_hit()

		AudioManager.play_hit()
		hit_object.take_damage(damage)

		var hit_marker = get_tree().current_scene.get_node_or_null("HUD/HitMarker")

		if hit_marker:
			hit_marker.show_hit()

		create_impact_particles(position, impact_color)

	elif is_instance_valid(hit_object):
		stats_panel.register_miss()
		AudioManager.play_miss()
		create_impact_particles(position, impact_color)

	else:
		stats_panel.register_miss()
		AudioManager.play_miss()

	if is_instance_valid(bullet):
		bullet.queue_free()


func create_impact_particles(
	impact_position: Vector3,
	particle_color: Color
) -> void:
	var particles := GPUParticles3D.new()

	particles.amount = particle_amount
	particles.lifetime = particle_lifetime
	particles.one_shot = true
	particles.explosiveness = 1.0

	var process_material := ParticleProcessMaterial.new()
	process_material.direction = Vector3.UP
	process_material.spread = 180.0
	process_material.initial_velocity_min = particle_speed_min
	process_material.initial_velocity_max = particle_speed_max
	process_material.gravity = Vector3.ZERO
	process_material.scale_min = 0.08
	process_material.scale_max = 0.14

	particles.process_material = process_material

	var sphere := SphereMesh.new()
	sphere.radius = 0.055
	sphere.height = 0.11

	var material := StandardMaterial3D.new()
	material.albedo_color = particle_color
	material.emission_enabled = true
	material.emission = particle_color
	material.emission_energy_multiplier = 3.0
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

	sphere.material = material
	particles.draw_pass_1 = sphere

	get_tree().current_scene.add_child(particles)
	particles.global_position = impact_position
	particles.emitting = true

	await get_tree().create_timer(particle_lifetime + 0.3).timeout

	if is_instance_valid(particles):
		particles.queue_free()
