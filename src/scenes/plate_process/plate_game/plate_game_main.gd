# res://src/scenes/plate_process/plate_game/plate_game_main.gd
# Lab 6: controlador de la partida "Arma tu plato" (equivalente a PizzaRushManager).
# Controla el progreso global: alimentos ubicados, tiempo y victoria/derrota.
# Cada alimento controla su propia FSM; este nodo solo escucha resultados.
#
# Lab 8 (UX): instrucciones progresivas según el estado del alimento, mano guía para el
# primer alimento (Reto 1), botón de ayuda que pausa el tiempo, retroalimentación en el
# mismo lugar donde mira el niño (+10 flotante, racha, sonido) y confeti al ganar (Reto 2).
extends Node2D

@export var game_duration: float = 150.0
@export var foods_on_table: int = 6
@export var perfect_bonus_value: int = 20
@export var perfect_bonus_minimum_score: int = 100
@export var idle_nudge_seconds: float = 10.0
@export var low_time_warning: float = 20.0

const HINT_START := "Toca un alimento y arrástralo hasta su grupo del plato"
const HINT_DRAGGING := "Suéltalo sobre el color de su grupo"
const HINT_WRONG := "¡Casi! Lee la pista del panel y vuelve a intentarlo"
const HINT_GOOD := "¡Muy bien! Sigue con el siguiente alimento"
const STREAK_STEPS := [3, 5, 8, 12]

@onready var timer_gameover: Timer = $TimerGameover
@onready var lbl_count: Label = $CanvasLayer/HUD/LblCount
@onready var lbl_time: Label = $CanvasLayer/HUD/LblTime
@onready var btn_help: Button = $CanvasLayer/HUD/BtnHelp
@onready var info_panel: PanelContainer = $CanvasLayer/InfoPanel
@onready var info_icon: TextureRect = $CanvasLayer/InfoPanel/VBox/HBoxTitle/Icon
@onready var info_title: Label = $CanvasLayer/InfoPanel/VBox/HBoxTitle/LblTitle
@onready var info_body: Label = $CanvasLayer/InfoPanel/VBox/LblBody
@onready var info_message_title: Label = $CanvasLayer/InfoPanel/VBox/LblMessageTitle
@onready var info_message: Label = $CanvasLayer/InfoPanel/VBox/LblMessage
@onready var result_panel: PanelContainer = $CanvasLayer/ResultPanel
@onready var info_style: StyleBoxFlat = info_panel.get_theme_stylebox("panel").duplicate()
@onready var hint_bar: PanelContainer = $CanvasLayer/HintBar
@onready var lbl_hint: Label = $CanvasLayer/HintBar/LblHint
@onready var streak_banner: Label = $CanvasLayer/StreakBanner
@onready var help_popup: Panel = $CanvasLayer/HelpPopup
@onready var btn_close_help: Button = $CanvasLayer/HelpPopup/Center/Card/VBox/HBoxTop/BtnClose
@onready var btn_show_hand: Button = $CanvasLayer/HelpPopup/Center/Card/VBox/BtnShowHand
@onready var hand: Sprite2D = $TutorialHand
@onready var float_layer: Node2D = $FloatLayer
@onready var confetti: CPUParticles2D = $Confetti

var game_over: bool = false
var streak: int = 0
var idle_time: float = 0.0
var last_drop_position: Vector2 = Vector2.ZERO
var hand_tween: Tween = null
var low_time_pulsing: bool = false


func _ready() -> void:
	info_panel.add_theme_stylebox_override("panel", info_style)
	# Cada visita empieza un plato nuevo
	EventBus.round_restart_requested.emit()
	EventBus.food_changed.connect(_on_food_changed)
	EventBus.placement_evaluated.connect(_on_placement_evaluated)
	EventBus.score_changed.connect(func(_s: int) -> void: _update_count())
	timer_gameover.timeout.connect(_on_general_timer_timeout)
	timer_gameover.start(game_duration)
	result_panel.hide()
	help_popup.hide()
	btn_help.pressed.connect(_open_help)
	btn_close_help.pressed.connect(_close_help)
	btn_show_hand.pressed.connect(func() -> void:
		_close_help()
		_start_tutorial_hand()
	)
	_setup_confetti()
	_show_instructions()
	_set_hint(HINT_START)
	_update_count()
	for i in foods_on_table:
		EventBus.next_food_requested.emit()
	# Reto 1: la mano guía aparece hasta que el niño ubica su primer alimento
	if not GlobalManager.settings.get("tutorial_done", false):
		get_tree().create_timer(0.8).timeout.connect(_start_tutorial_hand)


func _process(delta: float) -> void:
	if game_over:
		return
	lbl_time.text = "Tiempo: %d" % ceil(timer_gameover.time_left)
	if timer_gameover.time_left <= low_time_warning and not low_time_pulsing:
		_start_low_time_warning()
	if help_popup.visible:
		return
	idle_time += delta
	if idle_time >= idle_nudge_seconds:
		idle_time = 0.0
		var available := _available_foods()
		if not available.is_empty():
			available.pick_random().nudge()
			_set_hint(HINT_START)


# Bandejas de ESTA partida. No se usa get_nodes_in_group("food_tray") porque durante un
# fotograma la escena anterior (liberada con queue_free) sigue en el árbol con sus bandejas.
func _trays() -> Array:
	return $Trays.get_children()


func _available_foods() -> Array:
	var out: Array = []
	for tray in _trays():
		if tray.current_food and tray.current_food.current_state == 1:  # DISPONIBLE
			out.append(tray.current_food)
	return out


# GlobalManager entregó el siguiente alimento del mazo: ponerlo en una bandeja libre
func _on_food_changed(food_id: String) -> void:
	if food_id == "" or game_over:
		return
	var trays: Array = _trays().filter(func(t: Node) -> bool: return t.is_free())
	if trays.is_empty():
		return
	var food: Node = trays.pick_random().spawn_food(food_id)
	food.state_changed.connect(_on_food_state_changed)


# Lab 8: instrucciones progresivas a partir de la FSM de cada alimento
func _on_food_state_changed(food: Node, _from_state: int, to_state: int) -> void:
	idle_time = 0.0
	match to_state:
		2:  # ARRASTRANDO
			_set_hint(HINT_DRAGGING)
			_stop_tutorial_hand(false)
		3, 4:  # UBICADO / RECHAZADO: se guarda dónde soltó para mostrar el resultado ahí
			last_drop_position = food.global_position


func _on_placement_evaluated(food_id: String, group_id: String, correct: bool) -> void:
	if game_over:
		return
	_show_feedback(food_id, group_id, correct)
	_show_floating_result(correct)
	_update_count()
	if correct:
		streak += 1
		_set_hint(HINT_GOOD)
		if not GlobalManager.settings.get("tutorial_done", false):
			EventBus.tutorial_completed.emit()
		_stop_tutorial_hand(true)
		if streak in STREAK_STEPS:
			_show_streak()
		if GlobalManager.is_round_finished():
			finish_game()
		else:
			EventBus.next_food_requested.emit()
	else:
		streak = 0
		_set_hint(HINT_WRONG)


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


# --- Lab 8: retroalimentación en el lugar de la acción ----------------------------------

func _set_hint(text: String) -> void:
	if lbl_hint.text == text:
		return
	lbl_hint.text = text
	hint_bar.pivot_offset = hint_bar.size / 2.0
	var tween := create_tween()
	tween.tween_property(hint_bar, "scale", Vector2(1.05, 1.05), 0.08)
	tween.tween_property(hint_bar, "scale", Vector2.ONE, 0.12)


func _show_floating_result(correct: bool) -> void:
	var label := Label.new()
	label.text = "+%d" % GlobalManager.points["correct"] if correct else "¡Ups!"
	label.add_theme_font_size_override("font_size", 34 if correct else 28)
	label.add_theme_color_override("font_color", Color(1, 0.88, 0.3) if correct else Color(1, 0.55, 0.55))
	label.add_theme_constant_override("outline_size", 10)
	label.add_theme_color_override("font_outline_color", Color(0.05, 0.12, 0.09))
	float_layer.add_child(label)
	label.position = last_drop_position + Vector2(-30, -60)
	var tween := label.create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50, 0.8).set_ease(Tween.EASE_OUT)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


func _show_streak() -> void:
	streak_banner.text = "¡Racha x%d!" % streak
	streak_banner.show()
	streak_banner.scale = Vector2(0.4, 0.4)
	streak_banner.modulate.a = 1.0
	EventBus.sound_requested.emit("streak")
	var tween := create_tween()
	tween.tween_property(streak_banner, "scale", Vector2(1.15, 1.15), 0.18).set_trans(Tween.TRANS_BACK)
	tween.tween_property(streak_banner, "scale", Vector2.ONE, 0.1)
	tween.tween_interval(0.7)
	tween.tween_property(streak_banner, "modulate:a", 0.0, 0.3)
	tween.tween_callback(streak_banner.hide)


func _start_low_time_warning() -> void:
	low_time_pulsing = true
	lbl_time.add_theme_color_override("font_color", Color(1, 0.45, 0.4))
	var tween := create_tween().set_loops()
	tween.tween_property(lbl_time, "scale", Vector2(1.12, 1.12), 0.35)
	tween.tween_property(lbl_time, "scale", Vector2.ONE, 0.35)
	lbl_time.set_meta("pulse", tween)


func _setup_confetti() -> void:
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.2, 0.4, 0.6, 0.8, 1.0])
	gradient.colors = PackedColorArray([
		Color("f2c14e"), Color("6abf4b"), Color("4a90d9"), Color("e0533d"), Color("f08cb4"), Color("9b6bc9")])
	confetti.color_initial_ramp = gradient


# --- Lab 8, Reto 1: mano guía ----------------------------------------------------------

func _start_tutorial_hand() -> void:
	if game_over or (hand_tween and hand_tween.is_valid()):
		return
	var available := _available_foods()
	if available.is_empty():
		return
	var food: Node = available[0]
	var group_id: String = GlobalManager.foods[food.food_id]["group"]
	var target: Vector2 = food.global_position
	for sector in get_tree().get_nodes_in_group("plate_sector"):
		if sector.group_id == group_id and is_ancestor_of(sector):
			var mid: float = (sector.start_angle + sector.end_angle) / 2.0
			target = sector.global_position + Vector2(cos(mid), sin(mid)) * sector.radius * 0.55
	var start: Vector2 = food.global_position
	hand.global_position = start
	hand.modulate.a = 0.0
	hand.scale = Vector2.ONE
	hand.show()
	_set_hint("Mira la mano: toma el alimento y llévalo a su grupo")
	hand_tween = create_tween().set_loops()
	hand_tween.tween_property(hand, "modulate:a", 1.0, 0.25)
	hand_tween.tween_property(hand, "scale", Vector2(0.85, 0.85), 0.15)    # "presiona"
	hand_tween.tween_property(hand, "global_position", target, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	hand_tween.tween_property(hand, "scale", Vector2.ONE, 0.15)            # "suelta"
	hand_tween.tween_property(hand, "modulate:a", 0.0, 0.3)
	hand_tween.tween_callback(func() -> void: hand.global_position = start)
	hand_tween.tween_interval(0.4)


func _stop_tutorial_hand(_completed: bool) -> void:
	if hand_tween and hand_tween.is_valid():
		hand_tween.kill()
	hand_tween = null
	hand.hide()


# --- Lab 8: ayuda (convención "?") que pausa el tiempo ----------------------------------

func _open_help() -> void:
	if game_over:
		return
	timer_gameover.paused = true
	help_popup.show()
	EventBus.sound_requested.emit("click")


func _close_help() -> void:
	timer_gameover.paused = false
	help_popup.hide()
	idle_time = 0.0
	EventBus.sound_requested.emit("click")


# --- Fin de la partida ----------------------------------------------------------------

func _on_general_timer_timeout() -> void:
	_end_game()
	EventBus.sound_requested.emit("lose")
	show_panel("¡Se acabó el tiempo!",
		"Tu plato quedó incompleto. ¡Inténtalo otra vez!",
		"Alimentos ubicados: %d / %d" % [GlobalManager.selection["correct"], GlobalManager.round_size()],
		GlobalManager.GABA_MESSAGES[8])


func finish_game() -> void:
	_end_game()
	EventBus.sound_requested.emit("win")
	confetti.restart()
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
	_stop_tutorial_hand(false)
	if lbl_time.has_meta("pulse"):
		lbl_time.get_meta("pulse").kill()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	for tray in _trays():
		for child in tray.get_children():
			if child.has_method("lock"):
				child.lock()
	$CanvasLayer/HUD.hide()
	info_panel.hide()
	hint_bar.hide()
	help_popup.hide()


func _exit_tree() -> void:
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)


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
