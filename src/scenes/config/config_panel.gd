# res://src/scenes/config/config_panel.gd
extends Control

@onready var btn_back: Button = $VBox/BtnBack
@onready var chk_pistas: CheckButton = $VBox/ChkPistas


func _ready() -> void:
	# Opción de configuración comunicada por el EventBus (parameter_changed)
	chk_pistas.toggled.connect(func(activo: bool) -> void:
		EventBus.parameter_changed.emit("show_hints", activo)
	)
	btn_back.pressed.connect(func() -> void:
		EventBus.navigation_requested.emit("res://src/scenes/main/menu_panel.tscn")
	)
