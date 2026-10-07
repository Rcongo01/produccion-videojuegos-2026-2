# res://src/scenes/config/config_panel.gd
# Lab 4: el regreso usa ButtonNav. La preferencia de pistas se guarda en GlobalManager
# (vía EventBus), así sobrevive cuando esta pantalla se destruye.
extends Control

@onready var chk_pistas: CheckButton = $VBox/ChkPistas


func _ready() -> void:
	chk_pistas.button_pressed = GlobalManager.settings["show_hints"]
	chk_pistas.toggled.connect(func(activo: bool) -> void:
		EventBus.hints_toggled.emit(activo)
	)
