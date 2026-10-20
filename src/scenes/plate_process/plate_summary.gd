# res://src/scenes/plate_process/plate_summary.gd
# Lab 5: resumen del plato (equivalente a la factura de la guía).
# Lee el estado del GlobalManager, consulta la mejor estrella válida y la consume solo al confirmar.
# Lab 8: al confirmar se muestra PlateSuccessPopup (feedback claro del resultado de la acción).
extends Control

@onready var lbl_subtotal: Label = $Card/VBoxContainer/LblSubtotal
@onready var lbl_bonus: Label = $Card/VBoxContainer/LblBonus
@onready var lbl_total: Label = $Card/VBoxContainer/LblTotal
@onready var btn_confirm: Button = $Card/VBoxContainer/BtnConfirm
@onready var pop_up_confirm: Panel = $PlateSuccessPopup
@onready var popup_card: PanelContainer = $PlateSuccessPopup/Center/Card
@onready var popup_total: Label = $PlateSuccessPopup/Center/Card/VBox/LblTotal
@onready var popup_message: Label = $PlateSuccessPopup/Center/Card/VBox/LblMessage

var applied_bonus: Dictionary = {}
var final_total: int = 0


func _ready() -> void:
	btn_confirm.pressed.connect(_on_confirm)
	_update_summary()


func _on_confirm() -> void:
	if not applied_bonus.is_empty():
		GlobalManager.remove_bonus(applied_bonus)
	lbl_bonus.text = "¡Plato confirmado!"
	btn_confirm.disabled = true
	# El siguiente plato empieza desde cero
	EventBus.round_restart_requested.emit()
	_show_success_popup()


func _show_success_popup() -> void:
	popup_total.text = "Total: %d puntos" % final_total
	popup_message.text = "Tu plato saludable está listo. ¡Buen provecho!\n\n«%s»" % GlobalManager.GABA_MESSAGES[0]
	pop_up_confirm.show()
	EventBus.sound_requested.emit("win")
	pop_up_confirm.modulate.a = 0.0
	await get_tree().process_frame
	popup_card.pivot_offset = popup_card.size / 2.0
	popup_card.scale = Vector2(0.7, 0.7)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(pop_up_confirm, "modulate:a", 1.0, 0.2)
	tween.tween_property(popup_card, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _update_summary() -> void:
	var lines: Array[String] = []
	for group_id in GlobalManager.groups:
		lines.append("%s:  %d / %d" % [
			GlobalManager.groups[group_id]["short"],
			GlobalManager.selection["by_group"][group_id],
			GlobalManager.round_composition[group_id]])
	lines.append("Intentos fallidos: %d" % GlobalManager.selection["wrong"])
	lines.append("--------------------------------")
	var subtotal: int = GlobalManager.current_score
	lines.append("Subtotal: %d puntos" % subtotal)
	lbl_subtotal.text = "\n".join(lines)

	# Regla de negocio delegada al GlobalManager: mejor estrella válida
	applied_bonus = GlobalManager.get_best_bonus(subtotal)
	var bonus_value: int = 0
	if not applied_bonus.is_empty():
		bonus_value = applied_bonus["value"]
		lbl_bonus.text = "Estrella aplicada: +%d puntos (requiere %d puntos)" % [bonus_value, applied_bonus["minimum_score"]]
	elif not GlobalManager.bonuses.is_empty():
		lbl_bonus.text = "Tienes estrellas, pero tu plato aún no alcanza el puntaje mínimo."
	else:
		lbl_bonus.text = "Estrella aplicada: ninguna"
	final_total = max(subtotal + bonus_value, 0)
	lbl_total.text = "TOTAL: %d puntos" % final_total
	btn_confirm.disabled = GlobalManager.selection["correct"] == 0
