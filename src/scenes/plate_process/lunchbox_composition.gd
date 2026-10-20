# res://src/scenes/plate_process/lunchbox_composition.gd
# Lab 9: composición visual de la lonchera (equivalente a pizza_composition.gd de la guía).
# La guía usa dos mitades (LEFT / RIGHT); "Lonchera Express" usa cuatro compartimentos con la
# misma idea: un Button plano por compartimento, un ColorRect "Selection" y Tweens.
# Este componente solo maneja la REPRESENTACIÓN; el estado vive en GlobalManager.lunchbox_selection
# y se comunica por el EventBus (ingredient_selected).
extends Control

signal slot_selected(slot: int)

enum LunchboxSlot {
	BEBIDA,
	FRUTA,
	PRINCIPAL,
	SNACK
}

const SELECTED_COLOR := Color(1.0, 0.8, 0.2, 0.55)
const SELECTED_REST_COLOR := Color(1.0, 0.8, 0.2, 0.3)
const EMPTY_TEXTURE := preload("res://src/scenes/plate_process/assets/lunchbox/slot_empty.png")

var selected_slot: LunchboxSlot = LunchboxSlot.BEBIDA
var slot_ingredients: Array = [null, null, null, null]

@onready var slot_rects: Array[TextureRect] = [$SlotBebida, $SlotFruta, $SlotPrincipal, $SlotSnack]


func _ready() -> void:
	for i in slot_rects.size():
		slot_rects[i].get_node("Button").pressed.connect(_on_slot_pressed.bind(i))
	# Reto 4: al volver a la escena se reconstruye la lonchera desde el estado global
	_restore_from_state()
	update_selection_visual()


func _on_slot_pressed(slot: int) -> void:
	selected_slot = slot as LunchboxSlot
	EventBus.sound_requested.emit("click")
	update_selection_visual()


# Información que recibimos desde lunchbox_interactive.gd (llamada directa: misma interfaz)
func _on_ingredient_selected(ingredient: IngredientData) -> void:
	if ingredient == null:
		return
	# El cambio de estado se comunica al GlobalManager por el EventBus
	EventBus.ingredient_selected.emit(ingredient.id, selected_slot)
	_show_ingredient(selected_slot, ingredient)
	animate_lunchbox_update()
	# Mejora de UX: pasa solo al siguiente compartimento vacío
	for step in range(1, slot_rects.size()):
		var next := (selected_slot + step) % slot_rects.size()
		if slot_ingredients[next] == null:
			selected_slot = next as LunchboxSlot
			update_selection_visual()
			return


func _show_ingredient(slot: int, ingredient: IngredientData) -> void:
	slot_ingredients[slot] = ingredient
	var rect := slot_rects[slot]
	rect.texture = ingredient.texture if ingredient else EMPTY_TEXTURE
	rect.get_node("LblName").text = ingredient.display_name if ingredient else ""
	rect.get_node("LblName").visible = ingredient != null
	var seals: HBoxContainer = rect.get_node("Seals")
	for child in seals.get_children():
		child.queue_free()
	if ingredient == null:
		return
	for seal in ingredient.seals:
		var icon := TextureRect.new()
		icon.texture = GlobalManager.seal_texture(seal)
		icon.custom_minimum_size = Vector2(46, 46)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.tooltip_text = GlobalManager.SEAL_NAMES.get(seal, seal)
		seals.add_child(icon)
		# El sello "cae" sobre el compartimento
		icon.pivot_offset = Vector2(23, 23)
		icon.scale = Vector2(1.8, 1.8)
		create_tween().tween_property(icon, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _restore_from_state() -> void:
	for i in slot_rects.size():
		_show_ingredient(i, GlobalManager.get_ingredient(GlobalManager.lunchbox_selection[GlobalManager.LUNCHBOX_SLOTS[i]]))
	for i in slot_rects.size():
		if slot_ingredients[i] == null:
			selected_slot = i as LunchboxSlot
			return


# Vacía la representación (nuevo pedido)
func clear_view() -> void:
	for i in slot_rects.size():
		_show_ingredient(i, null)
	selected_slot = LunchboxSlot.BEBIDA
	update_selection_visual()


func selected_kind() -> String:
	return GlobalManager.LUNCHBOX_SLOTS[selected_slot]


func update_selection_visual() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	for i in slot_rects.size():
		var rect := slot_rects[i]
		var selection: ColorRect = rect.get_node("Selection")
		if i == selected_slot:
			# Destello de color y de escala en el compartimento activo
			tween.tween_property(selection, "color", SELECTED_COLOR, 0.10)
			tween.tween_property(selection, "color", SELECTED_REST_COLOR, 0.20).set_delay(0.10)
			tween.tween_property(rect, "scale", Vector2(1.04, 1.04), 0.10)
			tween.tween_property(rect, "scale", Vector2.ONE, 0.10).set_delay(0.10)
		else:
			# Los demás pierden la selección
			tween.tween_property(selection, "color", Color(1.0, 1.0, 1.0, 0.0), 0.12)
			tween.tween_property(rect, "scale", Vector2.ONE, 0.10)
	slot_selected.emit(selected_slot)


func animate_lunchbox_update() -> void:
	var target := slot_rects[selected_slot]
	target.scale = Vector2(0.85, 0.85)
	target.modulate = Color(1.0, 1.0, 1.0, 0.0)
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(target, "scale", Vector2.ONE, 0.18)
	tween.tween_property(target, "modulate", Color.WHITE, 0.18)
