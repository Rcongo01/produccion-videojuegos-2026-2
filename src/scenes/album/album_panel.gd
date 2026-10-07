# res://src/scenes/album/album_panel.gd
# Lab 7: álbum de los 6 grupos. Lee el progreso persistente (groups_learned) del GlobalManager.
# Los grupos aún no descubiertos se muestran bloqueados para motivar a seguir jugando.
extends Control

@onready var grid: GridContainer = $VBox/Grid


func _ready() -> void:
	for group_id in GlobalManager.groups:
		grid.add_child(_build_card(group_id, group_id in GlobalManager.groups_learned))


func _build_card(group_id: String, learned: bool) -> PanelContainer:
	var group: Dictionary = GlobalManager.groups[group_id]
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.17, 0.14, 0.9)
	style.border_color = group["color"] if learned else Color(1, 1, 1, 0.15)
	style.set_border_width_all(4)
	style.border_width_top = 14
	style.set_corner_radius_all(18)
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 14
	style.content_margin_bottom = 14
	card.add_theme_stylebox_override("panel", style)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	var title := Label.new()
	title.text = group["short"] if learned else "¿?"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", group["color"].lightened(0.2) if learned else Color(1, 1, 1, 0.6))
	vbox.add_child(title)

	var body := Label.new()
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.custom_minimum_size = Vector2(300, 0)
	body.add_theme_font_size_override("font_size", 15)
	if learned:
		body.text = "%s\n\n«%s»" % [group["function"], GlobalManager.group_message(group_id)]
	else:
		body.text = "Ubica en el plato un alimento de este grupo para descubrirlo."
		body.add_theme_color_override("font_color", Color(1, 1, 1, 0.55))
	vbox.add_child(body)
	return card
