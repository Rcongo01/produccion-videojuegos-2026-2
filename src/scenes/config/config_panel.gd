# res://src/scenes/config/config_panel.gd
# Lab 4: la preferencia de pistas vive en GlobalManager (vía EventBus).
# Lab 7: la preferencia se guarda en disco y se puede borrar el progreso (doble toque para confirmar).
extends Control

@onready var chk_pistas: CheckButton = $Card/VBox/ChkPistas
@onready var btn_reset: Button = $Card/VBox/BtnReset
@onready var lbl_reset: Label = $Card/VBox/LblReset

var reset_armed: bool = false


func _ready() -> void:
	chk_pistas.button_pressed = GlobalManager.settings["show_hints"]
	chk_pistas.toggled.connect(func(activo: bool) -> void:
		EventBus.hints_toggled.emit(activo)
	)
	btn_reset.pressed.connect(_on_reset_pressed)


func _on_reset_pressed() -> void:
	if not reset_armed:
		reset_armed = true
		btn_reset.text = "¿Seguro? Toca otra vez para borrar"
		return
	EventBus.progress_reset_requested.emit()
	reset_armed = false
	btn_reset.text = "Borrar mi progreso guardado"
	btn_reset.disabled = true
	lbl_reset.text = "Progreso borrado: récord, estrellas y grupos descubiertos."
