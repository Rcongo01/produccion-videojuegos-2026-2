# res://src/scenes/plate_process/lunchbox_interactive.gd
# Lab 9: "Lonchera Express" (equivalente a buy_panel_interactive.gd de la guía).
# Llegan niños con un pedido; el jugador arma una lonchera de 4 compartimentos antes de que se
# acabe el tiempo. La lista NO está hecha a mano: se genera un botón por cada IngredientData del
# catálogo (GlobalManager.ingredients) que corresponde al compartimento elegido.
extends Control

const BUTTON_HEIGHT := 64
const ICON_SIZE := 42
const SEAL_SIZE := 34
const LOW_TIME := 10.0
const SUMMARY_SCENE := "res://src/scenes/plate_process/lunchbox_summary.tscn"
const STAR_FULL := preload("res://src/assets/ui/star_full.png")
const STAR_EMPTY := preload("res://src/assets/ui/star_empty.png")
const KIND_TITLES := {
	"bebida": "Elige la bebida",
	"fruta": "Elige una fruta o verdura",
	"principal": "Elige el plato principal",
	"snack": "Elige el snack",
}

@onready var lbl_total: Label = $Card/VBoxContainer/LblTotal
@onready var lbl_kind: Label = $Card/VBoxContainer/LblKind
@onready var ingredient_list: Container = $Card/VBoxContainer/IngredientScroll/VBoxContainer/IngredientList
@onready var btn_continue: Button = $Card/VBoxContainer/HBoxButtons/BtnContinue
@onready var composition: Control = $LunchboxComposition
@onready var lbl_tip: Label = $TipRow/Bubble/LblTip
@onready var mascot: TextureRect = $TipRow/Mascot
@onready var avatar: TextureRect = $OrderCard/HBox/Avatar
@onready var lbl_order_title: Label = $OrderCard/HBox/VBox/LblOrderTitle
@onready var lbl_request: Label = $OrderCard/HBox/VBox/LblRequest
@onready var time_bar: ProgressBar = $OrderCard/HBox/VBox/TimeRow/TimeBar
@onready var lbl_time: Label = $OrderCard/HBox/VBox/TimeRow/LblTime
@onready var confetti: CPUParticles2D = $Confetti
@onready var result_popup: Panel = $ResultPopup
@onready var popup_card: PanelContainer = $ResultPopup/Center/Card
@onready var popup_avatar: TextureRect = $ResultPopup/Center/Card/VBox/HBoxKid/Avatar
@onready var popup_title: Label = $ResultPopup/Center/Card/VBox/HBoxKid/LblTitle
@onready var popup_stars: Array[TextureRect] = [$ResultPopup/Center/Card/VBox/Stars/Star1,
	$ResultPopup/Center/Card/VBox/Stars/Star2, $ResultPopup/Center/Card/VBox/Stars/Star3]
@onready var popup_points: Label = $ResultPopup/Center/Card/VBox/LblPoints
@onready var popup_feedback: Label = $ResultPopup/Center/Card/VBox/LblFeedback
@onready var btn_next: Button = $ResultPopup/Center/Card/VBox/BtnNext

var delivering: bool = false
var fill_style: StyleBoxFlat
var low_time_tween: Tween


func _ready() -> void:
	# Reto 4: si el niño sale al menú y vuelve, el pedido y la lonchera siguen como los dejó
	if not GlobalManager.is_lunch_round_active():
		GlobalManager.start_lunch_round()
		composition.clear_view()
	fill_style = time_bar.get_theme_stylebox("fill").duplicate()
	time_bar.add_theme_stylebox_override("fill", fill_style)
	composition.slot_selected.connect(_on_slot_selected)
	btn_continue.pressed.connect(_deliver)
	btn_next.pressed.connect(_on_next_pressed)
	# Señal para actualizar los puntos
	EventBus.lunchbox_total_changed.connect(_on_total_changed)
	_show_order()
	_on_slot_selected(composition.selected_slot)
	_on_total_changed(GlobalManager.lunchbox_total)


func _process(delta: float) -> void:
	if delivering or not GlobalManager.is_lunch_round_active():
		return
	GlobalManager.lunch_round["time_left"] = max(GlobalManager.lunch_round["time_left"] - delta, 0.0)
	_update_time()
	if GlobalManager.lunch_round["time_left"] <= 0.0:
		_deliver()


# --- Lista dinámica ----------------------------------------------------------------------
func _on_slot_selected(_slot: int) -> void:
	var kind: String = composition.selected_kind()
	lbl_kind.text = KIND_TITLES.get(kind, "Elige un alimento")
	_build_list(kind)


func _build_list(kind: String) -> void:
	for child in ingredient_list.get_children():
		ingredient_list.remove_child(child)
		child.queue_free()
	for ingredient in GlobalManager.ingredients:
		if ingredient.kind == kind:
			ingredient_list.add_child(_create_ingredient_button(ingredient))


# Presentación (Retos 2 y 3): ícono, nombre, puntos y los sellos del empaque. Los datos vienen
# del IngredientData; el formato del texto, los tamaños y el tooltip son decisiones de la interfaz.
func _create_ingredient_button(ingredient: IngredientData) -> Button:
	var button := Button.new()
	button.name = "Btn_" + ingredient.id
	button.text = "%s\n%d pts" % [ingredient.display_name, ingredient.price]
	button.icon = ingredient.icon
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.custom_minimum_size = Vector2(0, BUTTON_HEIGHT)
	button.add_theme_constant_override("icon_max_width", ICON_SIZE)
	button.add_theme_font_size_override("font_size", 17)
	# Los íconos de alimentos son a color: no se tiñen como los íconos blancos de la interfaz
	for state in ["icon_normal_color", "icon_hover_color", "icon_pressed_color", "icon_hover_pressed_color", "icon_focus_color"]:
		button.add_theme_color_override(state, Color.WHITE)
	button.tooltip_text = ingredient.tip
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if not ingredient.seals.is_empty():
		button.add_theme_constant_override("h_separation", 10)
		var seals := HBoxContainer.new()
		seals.name = "Seals"
		seals.mouse_filter = Control.MOUSE_FILTER_IGNORE
		seals.add_theme_constant_override("separation", 2)
		seals.anchor_left = 1.0
		seals.anchor_right = 1.0
		seals.anchor_top = 0.5
		seals.anchor_bottom = 0.5
		seals.offset_left = -8 - ingredient.seals.size() * (SEAL_SIZE + 2)
		seals.offset_right = -8
		seals.offset_top = -SEAL_SIZE / 2.0
		seals.offset_bottom = SEAL_SIZE / 2.0
		for seal in ingredient.seals:
			var icon := TextureRect.new()
			icon.texture = GlobalManager.seal_texture(seal)
			icon.custom_minimum_size = Vector2(SEAL_SIZE, SEAL_SIZE)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			seals.add_child(icon)
		button.add_child(seals)
	button.pressed.connect(_on_ingredient_selected.bind(ingredient))
	return button


func _on_ingredient_selected(ingredient: IngredientData) -> void:
	if ingredient == null or delivering:
		return
	composition._on_ingredient_selected(ingredient)
	lbl_tip.text = ingredient.tip
	EventBus.sound_requested.emit("pick" if ingredient.healthy else "wrong")
	_mascot_react(ingredient.healthy)


func _on_total_changed(new_total: int) -> void:
	lbl_total.text = "Puntos de la lonchera: %d" % new_total
	# Lab 8 (estado Disabled del Theme): solo se entrega con los cuatro compartimentos llenos
	btn_continue.disabled = not GlobalManager.is_lunchbox_complete()
	btn_continue.tooltip_text = "" if not btn_continue.disabled else "Llena los cuatro compartimentos"


# --- Pedido y tiempo ---------------------------------------------------------------------
func _show_order() -> void:
	var order: OrderData = GlobalManager.current_order()
	if order == null:
		return
	avatar.texture = order.avatar
	lbl_order_title.text = "Pedido %d de %d · %s" % [GlobalManager.lunch_round["index"] + 1,
		GlobalManager.lunch_round["orders"].size(), order.kid_name]
	lbl_request.text = "«%s»" % order.request
	time_bar.max_value = order.time_limit
	_update_time()
	# El niño "llega" con un pequeño salto
	avatar.pivot_offset = avatar.custom_minimum_size / 2.0
	avatar.scale = Vector2(0.6, 0.6)
	create_tween().tween_property(avatar, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_time() -> void:
	var t: float = GlobalManager.lunch_round["time_left"]
	time_bar.value = t
	lbl_time.text = "%d s" % ceili(t)
	var low := t <= LOW_TIME
	fill_style.bg_color = Color(0.91, 0.3, 0.3) if low else Color(0.42, 0.75, 0.29)
	lbl_time.add_theme_color_override("font_color", Color(1.0, 0.45, 0.45) if low else Color.WHITE)
	if low and low_time_tween == null:
		lbl_time.pivot_offset = lbl_time.size / 2.0
		low_time_tween = create_tween().set_loops()
		low_time_tween.tween_property(lbl_time, "scale", Vector2(1.2, 1.2), 0.25)
		low_time_tween.tween_property(lbl_time, "scale", Vector2.ONE, 0.25)
	elif not low and low_time_tween != null:
		low_time_tween.kill()
		low_time_tween = null
		lbl_time.scale = Vector2.ONE


# --- Entrega -----------------------------------------------------------------------------
func _deliver() -> void:
	if delivering or not GlobalManager.is_lunch_round_active():
		return
	delivering = true
	var order: OrderData = GlobalManager.current_order()
	var result: Dictionary = GlobalManager.deliver_lunchbox(GlobalManager.lunch_round["time_left"])
	_show_result(order, result)


func _show_result(order: OrderData, result: Dictionary) -> void:
	popup_avatar.texture = order.avatar
	var stars: int = result["stars"]
	popup_title.text = ("¡Gracias, %s!" if stars >= 2 else "%s esperaba otra cosa") % order.kid_name
	var detail := ""
	if result["met"]:
		detail += "pedido cumplido +%d" % order.bonus_points
	if result["time_bonus"] > 0:
		detail += ("  ·  " if detail != "" else "") + "rapidez +%d" % result["time_bonus"]
	popup_points.text = "+%d puntos" % result["points"] + ("\n(%s)" % detail if detail != "" else "")
	popup_feedback.text = "\n".join(result["lines"])
	btn_next.text = "Siguiente niño" if GlobalManager.is_lunch_round_active() else "Ver resultados"
	for star in popup_stars:
		star.texture = STAR_EMPTY
		star.scale = Vector2.ONE
	result_popup.show()
	result_popup.modulate.a = 0.0
	await get_tree().process_frame
	popup_card.pivot_offset = popup_card.size / 2.0
	popup_card.scale = Vector2(0.7, 0.7)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(result_popup, "modulate:a", 1.0, 0.2)
	tween.tween_property(popup_card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Las estrellas aparecen una por una
	for i in stars:
		await get_tree().create_timer(0.3).timeout
		if not is_inside_tree():
			return
		popup_stars[i].texture = STAR_FULL
		popup_stars[i].scale = Vector2(1.6, 1.6)
		create_tween().tween_property(popup_stars[i], "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		EventBus.sound_requested.emit("star")
	if stars == 3:
		confetti.restart()
		EventBus.sound_requested.emit("win")
	elif stars == 1:
		EventBus.sound_requested.emit("lose")


func _on_next_pressed() -> void:
	EventBus.sound_requested.emit("click")
	if not GlobalManager.is_lunch_round_active():
		EventBus.navigation_requested.emit(SUMMARY_SCENE, false)
		return
	result_popup.hide()
	composition.clear_view()
	lbl_tip.text = "¡Llegó otro niño! Lee su pedido con atención."
	_show_order()
	delivering = false


func _mascot_react(happy: bool) -> void:
	mascot.pivot_offset = mascot.size / 2.0
	var tween := create_tween()
	if happy:
		tween.tween_property(mascot, "scale", Vector2(1.15, 1.15), 0.12)
		tween.tween_property(mascot, "scale", Vector2.ONE, 0.12)
	else:
		tween.tween_property(mascot, "rotation", 0.18, 0.08)
		tween.tween_property(mascot, "rotation", -0.18, 0.08)
		tween.tween_property(mascot, "rotation", 0.0, 0.08)
