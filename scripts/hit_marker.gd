extends Control

var marker_alpha: float = 0.0
var marker_scale: float = 0.8
var hit_tween: Tween


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if marker_alpha > 0.0:
		queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var color := Color.WHITE
	color.a = marker_alpha

	var inner := 9.0 * marker_scale
	var outer := 17.0 * marker_scale
	var thickness := 2.0

	var directions := [
		Vector2(-1, -1),
		Vector2(1, -1),
		Vector2(-1, 1),
		Vector2(1, 1)
	]

	for direction in directions:
		draw_line(
			center + direction * outer,
			center + direction * inner,
			color,
			thickness,
			true
		)


func show_hit() -> void:
	if hit_tween and hit_tween.is_running():
		hit_tween.kill()

	marker_alpha = 1.0
	marker_scale = 0.8
	queue_redraw()

	hit_tween = create_tween()
	hit_tween.tween_property(self, "marker_scale", 1.15, 0.07)
	hit_tween.tween_property(self, "marker_scale", 1.0, 0.06)
	hit_tween.tween_interval(0.08)
	hit_tween.tween_property(self, "marker_alpha", 0.0, 0.15)
