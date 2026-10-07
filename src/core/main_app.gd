# res://src/core/main_app.gd
# Lab 3: orquestador central. Es el único que instancia y libera pantallas.
# Lab 4: historial de navegación como pila (append / pop_back).
extends Node

@onready var scene_container: Control = $SceneContainer

var current_scene: Node = null
var navigation_history: Array[String] = []


func _ready() -> void:
	EventBus.navigation_requested.connect(_on_navigation_requested)
	_on_navigation_requested("res://src/scenes/main/menu_panel.tscn", false)


func _on_navigation_requested(target_scene: String, discard_previous: bool) -> void:
	var target_packed: PackedScene = load(target_scene) if target_scene != "" else null
	if target_packed == null:
		printerr("Error: no se proporcionó una escena de navegación válida: ", target_scene)
		return

	if discard_previous:
		if navigation_history.size() > 0:
			navigation_history.pop_back()
	else:
		navigation_history.append(target_packed.resource_path)
	print("Historial de navegación: ", navigation_history)

	if current_scene:
		current_scene.queue_free()
		current_scene = null

	current_scene = target_packed.instantiate()
	scene_container.add_child(current_scene)
