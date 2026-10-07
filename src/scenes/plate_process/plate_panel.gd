# res://src/scenes/plate_process/plate_panel.gd  (antes step_1_base, renombrado en el Lab 5)
# Lab 4: interfaz reactiva del juego del plato.
#   - Los botones solo EMITEN intenciones al EventBus (food_placed, next_food_requested).
#   - GlobalManager evalúa, actualiza el puntaje y emite el resultado.
#   - Esta escena REACCIONA a food_changed, placement_evaluated y score_changed.
extends Control

@onready var txt_food: TextureRect = $VBoxContainer/HBoxFood/TxtFood
@onready var lbl_food: Label = $VBoxContainer/HBoxFood/LblFood
@onready var lbl_info: Label = $VBoxContainer/LblInfo
@onready var lbl_score: Label = $VBoxContainer/HBoxBottom/LblScore
@onready var btn_siguiente: Button = $VBoxContainer/HBoxBottom/BtnSiguiente
@onready var group_buttons: Dictionary = {
	"cereales": $VBoxContainer/GridContainer/BtnCereales,
	"frutas_verduras": $VBoxContainer/GridContainer/BtnFrutasVerduras,
	"lacteos": $VBoxContainer/GridContainer/BtnLacteos,
	"carnes": $VBoxContainer/GridContainer/BtnCarnes,
	"grasas": $VBoxContainer/GridContainer/BtnGrasas,
	"azucares": $VBoxContainer/GridContainer/BtnAzucares,
}

var current_food: String = ""


func _ready() -> void:
	for group_id in group_buttons:
		var btn: Button = group_buttons[group_id]
		btn.text = GlobalManager.groups[group_id]["short"]
		_paint_button(btn, GlobalManager.groups[group_id]["color"])
		btn.pressed.connect(_on_group_pressed.bind(group_id))

	btn_siguiente.pressed.connect(_on_siguiente_pressed)
	EventBus.food_changed.connect(_on_food_changed)
	EventBus.placement_evaluated.connect(_on_placement_evaluated)
	EventBus.score_changed.connect(_on_score_changed)

	_on_score_changed(GlobalManager.current_score)
	if GlobalManager.selection["food"] == "":
		EventBus.next_food_requested.emit()
	else:
		_on_food_changed(GlobalManager.selection["food"])


func _on_group_pressed(group_id: String) -> void:
	if current_food != "":
		EventBus.food_placed.emit(current_food, group_id)


func _on_siguiente_pressed() -> void:
	if GlobalManager.is_round_finished():
		EventBus.round_restart_requested.emit()
	EventBus.next_food_requested.emit()


func _on_food_changed(food_id: String) -> void:
	current_food = food_id
	_set_group_buttons_enabled(food_id != "")
	btn_siguiente.text = "Siguiente alimento"
	# Solo se avanza después de responder (evita saltar alimentos de la ronda)
	btn_siguiente.disabled = food_id != ""
	if food_id == "":
		txt_food.texture = null
		lbl_food.text = "¡Plato completo!"
		return
	txt_food.texture = load(GlobalManager.food_texture_path(food_id))
	lbl_food.text = GlobalManager.foods[food_id]["name"]
	lbl_info.text = "Toca el grupo al que pertenece."


func _on_placement_evaluated(food_id: String, group_id: String, correct: bool) -> void:
	var food_name: String = GlobalManager.foods[food_id]["name"]
	var group: Dictionary = GlobalManager.groups[group_id]
	if correct:
		lbl_info.text = "¡Muy bien! %s es del grupo «%s».\n%s %s\n\nMensaje de las Guías Alimentarias: «%s»" % [
			food_name, group["name"], group["function"], group["importance"],
			GlobalManager.group_message(group_id)]
	else:
		lbl_info.text = "¡Casi! %s no va en «%s»." % [food_name, group["short"]]
		if GlobalManager.settings["show_hints"]:
			var right: Dictionary = GlobalManager.groups[GlobalManager.foods[food_id]["group"]]
			lbl_info.text += "\nPista: busca el grupo que «%s»" % right["function"].to_lower()
		lbl_info.text += "\nLo verás de nuevo más adelante."
	current_food = ""
	_set_group_buttons_enabled(false)
	btn_siguiente.disabled = false
	if GlobalManager.is_round_finished():
		lbl_info.text += "\n\n¡Completaste tu plato! " + GlobalManager.GABA_MESSAGES[0]
		btn_siguiente.text = "Jugar otra vez"


func _on_score_changed(new_score: int) -> void:
	lbl_score.text = "Puntos: %d   ·   Aciertos: %d / %d" % [
		new_score, GlobalManager.selection["correct"], GlobalManager.round_size()]


func _set_group_buttons_enabled(enabled: bool) -> void:
	for group_id in group_buttons:
		group_buttons[group_id].disabled = not enabled


# Botón con el color de su división en el Plato saludable de la Familia Colombiana
func _paint_button(btn: Button, color: Color) -> void:
	for state in ["normal", "hover", "pressed", "disabled", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = color
		if state == "hover":
			sb.bg_color = color.lightened(0.15)
		elif state == "pressed":
			sb.bg_color = color.darkened(0.15)
		elif state == "disabled":
			sb.bg_color = color.darkened(0.45)
		elif state == "focus":
			sb.draw_center = false
			sb.border_color = Color.WHITE
			sb.set_border_width_all(3)
		sb.set_corner_radius_all(10)
		btn.add_theme_stylebox_override(state, sb)
	btn.add_theme_color_override("font_color", Color(0.1, 0.1, 0.12))
	btn.add_theme_color_override("font_hover_color", Color(0.1, 0.1, 0.12))
	btn.add_theme_color_override("font_pressed_color", Color(0.1, 0.1, 0.12))
	btn.add_theme_font_size_override("font_size", 18)
