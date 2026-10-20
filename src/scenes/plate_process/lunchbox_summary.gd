# res://src/scenes/plate_process/lunchbox_summary.gd
# Lab 9: resultados de "Lonchera Express" (equivalente a purchase_invoice_interactive.gd de la guía).
# Es una copia del resumen del plato que cambia SOLO la información que presenta: ahora lee los
# resultados de la ronda (GlobalManager.lunch_round). Las estrellas de bonificación se reutilizan
# sin cambios (get_best_bonus / remove_bonus), igual que los cupones en la guía.
extends Control

const STAR_FULL := preload("res://src/assets/ui/star_full.png")
const STAR_EMPTY := preload("res://src/assets/ui/star_empty.png")

@onready var kid_list: VBoxContainer = $Card/VBoxContainer/HBox/KidList
@onready var lbl_subtotal: Label = $Card/VBoxContainer/HBox/Info/LblSubtotal
@onready var lbl_advice: Label = $Card/VBoxContainer/HBox/Info/LblAdvice
@onready var lbl_bonus: Label = $Card/VBoxContainer/HBox/Info/LblBonus
@onready var lbl_total: Label = $Card/VBoxContainer/HBox/Info/LblTotal
@onready var lbl_record: Label = $Card/VBoxContainer/HBox/Info/LblRecord
@onready var btn_confirm: Button = $Card/VBoxContainer/HBoxButtons/BtnConfirm
@onready var btn_back: Button = $Card/VBoxContainer/HBoxButtons/BtnBack
@onready var pop_up_confirm: Panel = $LunchboxSuccessPopup
@onready var popup_card: PanelContainer = $LunchboxSuccessPopup/Center/Card
@onready var popup_message: Label = $LunchboxSuccessPopup/Center/Card/VBox/LblMessage
@onready var popup_total: Label = $LunchboxSuccessPopup/Center/Card/VBox/LblTotal

var applied_bonus: Dictionary = {}
var final_total: int = 0


func _ready() -> void:
	btn_confirm.pressed.connect(_on_confirm)
	_update_invoice()


func _on_confirm() -> void:
	if not applied_bonus.is_empty():
		GlobalManager.remove_bonus(applied_bonus)
	lbl_bonus.text = "¡Ronda confirmada!"
	btn_confirm.disabled = true
	btn_back.disabled = true
	var record := GlobalManager.register_lunch_score(final_total)
	_show_success_popup(record)


func _show_success_popup(record: bool) -> void:
	var results: Array = GlobalManager.lunch_round["results"]
	popup_total.text = "Total: %d puntos" % final_total
	popup_message.text = "Repartiste %d loncheras y ganaste %d de %d estrellas.%s" % [
		results.size(), GlobalManager.lunch_round_stars(), results.size() * 3,
		"\n\n¡Nuevo récord!" if record else ""]
	pop_up_confirm.show()
	EventBus.sound_requested.emit("win")
	pop_up_confirm.modulate.a = 0.0
	await get_tree().process_frame
	popup_card.pivot_offset = popup_card.size / 2.0
	popup_card.scale = Vector2(0.7, 0.7)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(pop_up_confirm, "modulate:a", 1.0, 0.2)
	tween.tween_property(popup_card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_invoice() -> void:
	var results: Array = GlobalManager.lunch_round["results"]
	var unhealthy := 0
	# Una fila por niño, generada a partir de los resultados (avatar, puntos y estrellas)
	for result in results:
		kid_list.add_child(_create_kid_row(result))
		unhealthy += result["unhealthy"]

	var subtotal: int = GlobalManager.lunch_round["total"]
	var stars := GlobalManager.lunch_round_stars()
	lbl_subtotal.text = (
		"Loncheras entregadas: %d\n"
		+ "Estrellas de los niños: %d / %d\n"
		+ "--------------------------------\n"
		+ "Subtotal: %d puntos"
	) % [results.size(), stars, results.size() * 3, subtotal]

	if results.is_empty():
		lbl_advice.text = "Nutri dice: todavía no has entregado loncheras."
	elif unhealthy == 0:
		lbl_advice.text = "Nutri dice: ¡cero ultraprocesados en toda la ronda! Eres un experto en loncheras."
	else:
		lbl_advice.text = "Nutri dice: pusiste %d ultraprocesados. Busca los sellos negros y cámbialos por fruta o agua." % unhealthy
	lbl_advice.add_theme_color_override("font_color", Color(0.6, 0.88, 0.5) if unhealthy == 0 else Color(1.0, 0.72, 0.45))

	# Regla de negocio delegada al GlobalManager: la mejor estrella válida
	applied_bonus = GlobalManager.get_best_bonus(subtotal)
	var bonus_value := 0
	if not applied_bonus.is_empty():
		bonus_value = applied_bonus["value"]
		lbl_bonus.text = "Estrella aplicada: +%d puntos (requiere %d)" % [bonus_value, applied_bonus["minimum_score"]]
	elif not GlobalManager.bonuses.is_empty():
		lbl_bonus.text = "Tienes estrellas, pero esta ronda aún no alcanza el puntaje mínimo."
	else:
		lbl_bonus.text = "Estrella aplicada: ninguna (gánalas en Ganar estrellas)"
	final_total = max(subtotal + bonus_value, 0)
	lbl_total.text = "TOTAL: %d puntos" % final_total
	lbl_record.text = ("¡Nuevo récord! (antes: %d puntos)" if final_total > GlobalManager.lunch_best else "Récord: %d puntos") % GlobalManager.lunch_best
	btn_confirm.disabled = results.is_empty()


func _create_kid_row(result: Dictionary) -> HBoxContainer:
	var order: OrderData = result["order"]
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var face := TextureRect.new()
	face.texture = order.avatar
	face.custom_minimum_size = Vector2(56, 56)
	face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	row.add_child(face)
	var name_label := Label.new()
	name_label.text = "%s  ·  %d pts" % [order.kid_name, result["points"]]
	name_label.add_theme_font_size_override("font_size", 19)
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(name_label)
	for i in 3:
		var star := TextureRect.new()
		star.texture = STAR_FULL if i < result["stars"] else STAR_EMPTY
		star.custom_minimum_size = Vector2(30, 30)
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		row.add_child(star)
	return row
