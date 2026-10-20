# res://src/scenes/config/config_panel.gd
# Lab 4: la preferencia de pistas vive en GlobalManager (vía EventBus).
# Lab 7: la preferencia se guarda en disco y se puede borrar el progreso (doble toque para confirmar).
# Lab 8: opción para activar o desactivar los sonidos; el ícono de papelera refuerza "eliminar".
extends Control

@onready var chk_pistas: CheckButton = $Card/VBox/ChkPistas
@onready var chk_sonido: CheckButton = $Card/VBox/ChkSonido
@onready var btn_reset: Button = $Card/VBox/BtnReset
@onready var lbl_reset: Label = $Card/VBox/LblReset

var reset_armed: bool = false


func _ready() -> void:
	chk_pistas.button_pressed = GlobalManager.settings["show_hints"]
	chk_sonido.button_pressed = GlobalManager.settings["sound_enabled"]
	chk_pistas.toggled.connect(func(activo: bool) -> void:
		EventBus.hints_toggled.emit(activo)
	)
	chk_sonido.toggled.connect(func(activo: bool) -> void:
		EventBus.sound_toggled.emit(activo)
		EventBus.sound_requested.emit("click")
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
