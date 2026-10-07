# res://src/scenes/plate_process/plate_game/plate_sector.gd
# Lab 6: una división del plato (equivalente al "horno" de la guía).
# Es un Area2D en el grupo "plate_sector"; no decide el estado del alimento,
# solo reacciona visualmente al resultado (activate / reject) y resalta al pasar por encima.
extends Area2D

@export var group_id: String = ""
@export var radius: float = 210.0
@export var start_angle: float = 0.0  # radianes
@export var end_angle: float = PI / 2.0

@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

var color: Color = Color.WHITE
var label_text: String = ""
var highlighted: bool = false


func setup(p_group_id: String, p_radius: float, p_start: float, p_end: float) -> void:
	group_id = p_group_id
	radius = p_radius
	start_angle = p_start
	end_angle = p_end


func _ready() -> void:
	add_to_group("plate_sector")
	color = GlobalManager.groups[group_id]["color"]
	label_text = GlobalManager.groups[group_id]["label"]
	collision.polygon = _wedge_points(radius)


func _wedge_points(r: float) -> PackedVector2Array:
	var points := PackedVector2Array([Vector2.ZERO])
	var steps: int = max(int((end_angle - start_angle) / 0.06), 3)
	for i in steps + 1:
		var a: float = lerp(start_angle, end_angle, float(i) / steps)
		points.append(Vector2(cos(a), sin(a)) * r)
	return points


func _draw() -> void:
	var fill: Color = color.lightened(0.25) if highlighted else color
	draw_colored_polygon(_wedge_points(radius), fill)
	draw_polyline(_wedge_points(radius) + PackedVector2Array([Vector2.ZERO]), Color.WHITE, 4.0, true)
	# Nombre del grupo en el centro de la división
	var mid: float = (start_angle + end_angle) / 2.0
	var small: bool = (end_angle - start_angle) < 0.6
	var center: Vector2 = Vector2(cos(mid), sin(mid)) * radius * (0.76 if small else 0.62)
	var project_theme: Theme = ThemeDB.get_project_theme()
	var font: Font = project_theme.default_font if project_theme and project_theme.default_font else ThemeDB.fallback_font
	var lines: PackedStringArray = label_text.split("\n")
	var font_size: int = 14 if small else (15 if lines.size() > 1 else 17)
	var y: float = center.y - (lines.size() - 1) * font_size * 0.6
	for line in lines:
		var w: float = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var pos := Vector2(center.x - w / 2.0, y + font_size * 0.35)
		draw_string_outline(font, pos, line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, Color(1, 1, 1, 0.85))
		draw_string(font, pos, line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.12, 0.12, 0.14))
		y += font_size * 1.2


# Punto aleatorio dentro de la división para dejar el alimento ubicado
func random_point_inside() -> Vector2:
	var margin: float = min(0.12, (end_angle - start_angle) * 0.25)
	var a: float = randf_range(start_angle + margin, end_angle - margin)
	# Se evita la franja donde está escrito el nombre del grupo
	var small: bool = (end_angle - start_angle) < 0.6
	var r: float
	if small or randf() < 0.6:
		r = randf_range(radius * 0.22, radius * (0.52 if small else 0.45))
	else:
		r = randf_range(radius * 0.8, radius * 0.88)
	return global_position + Vector2(cos(a), sin(a)) * r


func set_highlight(value: bool) -> void:
	if highlighted != value:
		highlighted = value
		queue_redraw()


func activate() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.4, 1.4, 1.4), 0.12)
	tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func reject() -> void:
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 0.55, 0.55), 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.3)
