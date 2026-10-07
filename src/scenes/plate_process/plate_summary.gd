# res://src/scenes/plate_process/plate_summary.gd
# Lab 5: resumen del plato (equivalente a la factura de la guía).
# Lee el estado del GlobalManager, consulta la mejor estrella válida y la consume solo al confirmar.
extends Control

@onready var lbl_subtotal: Label = $Card/VBoxContainer/LblSubtotal
@onready var lbl_bonus: Label = $Card/VBoxContainer/LblBonus
@onready var lbl_total: Label = $Card/VBoxContainer/LblTotal
@onready var btn_confirm: Button = $Card/VBoxContainer/BtnConfirm

var applied_bonus: Dictionary = {}


func _ready() -> void:
	btn_confirm.pressed.connect(_on_confirm)
	_update_summary()


func _on_confirm() -> void:
	if not applied_bonus.is_empty():
		GlobalManager.remove_bonus(applied_bonus)
	lbl_bonus.text = "¡Plato confirmado! " + GlobalManager.GABA_MESSAGES[0]
	btn_confirm.disabled = true
	# El siguiente plato empieza desde cero
	EventBus.round_restart_requested.emit()


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
	var final_total: int = max(subtotal + bonus_value, 0)
	lbl_total.text = "TOTAL: %d puntos" % final_total
	btn_confirm.disabled = GlobalManager.selection["correct"] == 0
