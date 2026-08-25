extends Control

func _ready() -> void:
	print("Sistema interactivo inicializado con éxito")
	
func _on_btn_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/main_level_1.tscn")
