extends Control

@export var crosshair_size: float = 12.0
@export var thickness: float = 2.0
@export var gap: float = 4.0
@export var crosshair_color: Color = Color("#00E5FF")


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _draw() -> void:
	var center := size * 0.5
	var half_thickness := thickness * 0.5

	var horizontal_y := center.y - half_thickness
	var vertical_x := center.x - half_thickness

	var lines := [
		Rect2(center.x - gap - crosshair_size, horizontal_y, crosshair_size, thickness),
		Rect2(center.x + gap, horizontal_y, crosshair_size, thickness),
		Rect2(vertical_x, center.y - gap - crosshair_size, thickness, crosshair_size),
		Rect2(vertical_x, center.y + gap, thickness, crosshair_size)
	]

	for line in lines:
		draw_rect(line, crosshair_color)
