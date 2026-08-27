extends Node

func cambiar_de_escena_nivel() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_level_1.tscn")

func cambiar_de_escena_menu() -> void:
	get_tree().change_scene_to_file("res://src/scenes/menu/menu_panel.tscn")

func _on_btn_iniciar_pressed_navigation() -> void:
	cambiar_de_escena_nivel()

func _on_btn_volver_pressed_navigation() -> void:
	cambiar_de_escena_menu()
