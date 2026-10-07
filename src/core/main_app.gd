# res://src/core/main_app.gd
# Lab 3: orquestador central. Es el único que instancia y libera pantallas.
extends Node

@onready var scene_container: Control = $SceneContainer

# Pantalla activa en memoria
var current_scene: Node = null


func _ready() -> void:
	# 1. Suscribir el orquestador al EventBus global
	EventBus.navigation_requested.connect(_on_navigation_requested)
	EventBus.parameter_changed.connect(_on_parameter_changed)
	# 2. Cargar la pantalla inicial (menú)
	_on_navigation_requested("res://src/scenes/main/menu_panel.tscn")


func _on_navigation_requested(target_scene_path: String) -> void:
	# A. Liberar la pantalla anterior para evitar fugas de memoria
	if current_scene:
		current_scene.queue_free()
		current_scene = null

	# B. Cargar e instanciar la nueva pantalla dentro del contenedor
	var new_scene_resource: PackedScene = load(target_scene_path)
	if new_scene_resource:
		current_scene = new_scene_resource.instantiate()
		scene_container.add_child(current_scene)
	else:
		printerr("Error crítico de arquitectura: no se pudo cargar la escena: ", target_scene_path)


func _on_parameter_changed(param_name: String, value: Variant) -> void:
	print("Parámetro modificado: %s = %s" % [param_name, str(value)])
