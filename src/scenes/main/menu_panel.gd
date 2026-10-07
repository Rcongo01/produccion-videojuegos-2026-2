# res://src/scenes/main/menu_panel.gd
# Lab 3: el menú ya no cambia de escena; solo emite intenciones al EventBus.
extends Control

@onready var btn_simulation: Button = $VBoxMenu/BtnSimulacion
@onready var btn_config: Button = $VBoxMenu/BtnConfig
@onready var btn_credits: Button = $VBoxMenu/BtnCredits
@onready var btn_exit: Button = $VBoxMenu/BtnExit


func _ready() -> void:
	# Lambdas inline que emiten la solicitud de navegación global
	btn_simulation.pressed.connect(func() -> void:
		EventBus.navigation_requested.emit("res://src/scenes/simulation/step_1_base.tscn")
	)
	btn_config.pressed.connect(func() -> void:
		EventBus.navigation_requested.emit("res://src/scenes/config/config_panel.tscn")
	)
	btn_credits.pressed.connect(func() -> void:
		EventBus.navigation_requested.emit("res://src/scenes/credits/credits_panel.tscn")
	)
	btn_exit.pressed.connect(func() -> void:
		get_tree().quit()
	)
