# res://src/scenes/plate_process/plate_game/plate_game_main.gd
# Lab 6: controlador de la partida "Arma tu plato" (equivalente a PizzaRushManager).
# Controla el progreso global: alimentos ubicados, tiempo y victoria/derrota.
# Cada alimento controla su propia FSM; este nodo solo escucha resultados.
extends Node2D

@export var game_duration: float = 150.0
@export var foods_on_table: int = 6
@export var perfect_bonus_value: int = 20
@export var perfect_bonus_minimum_score: int = 100

@onready var timer_gameover: Timer = $TimerGameover
@onready var lbl_count: Label = $CanvasLayer/HUD/LblCount
@onready var lbl_time: Label = $CanvasLayer/HUD/LblTime
@onready var info_panel: PanelContainer = $CanvasLayer/InfoPanel
@onready var info_icon: TextureRect = $CanvasLayer/InfoPanel/VBox/HBoxTitle/Icon
@onready var info_title: Label = $CanvasLayer/InfoPanel/VBox/HBoxTitle/LblTitle
@onready var info_body: Label = $CanvasLayer/InfoPanel/VBox/LblBody
@onready var info_message_title: Label = $CanvasLayer/InfoPanel/VBox/LblMessageTitle
@onready var info_message: Label = $CanvasLayer/InfoPanel/VBox/LblMessage
@onready var result_panel: PanelContainer = $CanvasLayer/ResultPanel
@onready var info_style: StyleBoxFlat = info_panel.get_theme_stylebox("panel")

var game_over: bool = false


func _ready() -> void:
	# Cada visita empieza un plato nuevo
	EventBus.round_restart_requested.emit()
	EventBus.food_changed.connect(_on_food_changed)
	EventBus.placement_evaluated.connect(_on_placement_evaluated)
	EventBus.score_changed.connect(func(_s: int) -> void: _update_count())
	timer_gameover.timeout.connect(_on_general_timer_timeout)
	timer_gameover.start(game_duration)
	result_panel.hide()
	_show_instructions()
	_update_count()
	for i in foods_on_table:
		EventBus.next_food_requested.emit()


func _process(_delta: float) -> void:
	if not game_over:
		lbl_time.text = "Tiempo: %d" % ceil(timer_gameover.time_left)


# Bandejas de ESTA partida. No se usa get_nodes_in_group("food_tray") porque durante un
# fotograma la escena anterior (liberada con queue_free) sigue en el árbol con sus bandejas.
func _trays() -> Array:
	return $Trays.get_children()


# GlobalManager entregó el siguiente alimento del mazo: ponerlo en una bandeja libre
func _on_food_changed(food_id: String) -> void:
	if food_id == "" or game_over:
		return
	var trays: Array = _trays().filter(func(t: Node) -> bool: return t.is_free())
	if trays.is_empty():
		return
	trays.pick_random().spawn_food(food_id)


func _on_placement_evaluated(food_id: String, group_id: String, correct: bool) -> void:
	if game_over:
		return
	_show_feedback(food_id, group_id, correct)
	_update_count()
	if correct:
		if GlobalManager.is_round_finished():
			finish_game()
		else:
			EventBus.next_food_requested.emit()


func _update_count() -> void:
	lbl_count.text = "Alimentos: %d / %d   ·   Puntos: %d" % [
		GlobalManager.selection["correct"], GlobalManager.round_size(), GlobalManager.current_score]


# --- Panel de información del grupo ----------------------------------------------------

func _show_instructions() -> void:
	info_icon.texture = null
	info_title.text = "Arma tu plato"
	info_body.text = "Arrastra cada alimento hasta su grupo en el Plato saludable de la Familia Colombiana.\n\nCuando lo ubiques bien, aquí aprenderás para qué sirve ese grupo."
	info_message_title.text = "Mensaje de las Guías Alimentarias"
	info_message.text = "«%s»" % GlobalManager.GABA_MESSAGES[0]
	info_style.border_color = Color(1, 1, 1, 0.4)


func _show_feedback(food_id: String, group_id: String, correct: bool) -> void:
	var food_name: String = GlobalManager.foods[food_id]["name"]
	info_icon.texture = load(GlobalManager.food_texture_path(food_id))
	if correct:
		var group: Dictionary = GlobalManager.groups[group_id]
		info_title.text = "¡Muy bien! %s va en %s" % [food_name, group["short"]]
		info_body.text = "¿Para qué sirve?\n%s\n\n¿Por qué es importante?\n%s" % [group["function"], group["importance"]]
		info_message_title.text = "Mensaje de las Guías Alimentarias"
		info_message.text = "«%s»" % GlobalManager.group_message(group_id)
		info_style.border_color = group["color"]
	else:
		var wrong: Dictionary = GlobalManager.groups[group_id]
		info_title.text = "¡Casi! %s no va en %s" % [food_name, wrong["short"]]
		info_body.text = "Inténtalo de nuevo: el alimento volvió a su lugar."
		if GlobalManager.settings["show_hints"]:
			var right: Dictionary = GlobalManager.groups[GlobalManager.foods[food_id]["group"]]
			info_body.text += "\n\nPista: busca el grupo que %s" % right["function"].to_lower()
		info_message_title.text = ""
		info_message.text = ""
		info_style.border_color = Color(0.95, 0.4, 0.4)
	# Pequeña animación para llamar la atención sobre el panel
	info_panel.pivot_offset = info_panel.size / 2.0
	var tween := create_tween()
	tween.tween_property(info_panel, "scale", Vector2(1.04, 1.04), 0.08)
	tween.tween_property(info_panel, "scale", Vector2.ONE, 0.12)


# --- Fin de la partida ----------------------------------------------------------------

func _on_general_timer_timeout() -> void:
	_end_game()
	show_panel("¡Se acabó el tiempo!",
		"Tu plato quedó incompleto. ¡Inténtalo otra vez!",
		"Alimentos ubicados: %d / %d" % [GlobalManager.selection["correct"], GlobalManager.round_size()],
		GlobalManager.GABA_MESSAGES[8])


func finish_game() -> void:
	_end_game()
	var desc: String = "Completaste el Plato saludable de la Familia Colombiana."
	if GlobalManager.selection["wrong"] == 0:
		# Plato perfecto: la recompensa se comunica por el EventBus (como en la guía)
		EventBus.bonus_obtained.emit({
			"value": perfect_bonus_value,
			"minimum_score": perfect_bonus_minimum_score,
		})
		desc += "\n¡Sin errores! Ganaste una estrella de +%d puntos." % perfect_bonus_value
	show_panel("¡Plato completo!", desc,
		"Alimentos ubicados: %d / %d · Errores: %d" % [
			GlobalManager.selection["correct"], GlobalManager.round_size(), GlobalManager.selection["wrong"]],
		GlobalManager.GABA_MESSAGES.pick_random())


func _end_game() -> void:
	if game_over:
		return
	game_over = true
	timer_gameover.stop()
	for tray in _trays():
		for child in tray.get_children():
			if child.has_method("lock"):
				child.lock()
	$CanvasLayer/HUD.hide()
	info_panel.hide()


func show_panel(title: String, desc: String, count: String, message: String) -> void:
	result_panel.get_node("VBox/LblTitle").text = title
	result_panel.get_node("VBox/LblDesc").text = desc
	result_panel.get_node("VBox/LblCount").text = count
	result_panel.get_node("VBox/LblMessage").text = "Mensaje de las Guías Alimentarias:\n«%s»" % message
	result_panel.show()
	result_panel.pivot_offset = result_panel.size / 2.0
	result_panel.scale = Vector2(0.6, 0.6)
	var tween := create_tween()
	tween.tween_property(result_panel, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
