# res://src/scenes/main/menu_panel.gd
# Lab 4: la navegación la hacen las instancias de ButtonNav (configuradas en el Inspector).
# Cerrar la aplicación no es una navegación entre escenas, por eso sigue siendo un Button normal.
extends Control

@onready var btn_exit: Button = $VBoxMenu/BtnExit


func _ready() -> void:
	btn_exit.pressed.connect(func() -> void:
		get_tree().quit()
	)
