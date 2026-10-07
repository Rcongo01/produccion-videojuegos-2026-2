# res://src/components/navigation/button_nav.gd
# Lab 4: botón de navegación reutilizable. Su destino se configura en el Inspector.
extends Button

@export_file("*.tscn") var target_scene: String
# Indica que la navegación retira la última entrada del historial (pila)
@export var discard_previous: bool = false


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	EventBus.navigation_requested.emit(target_scene, discard_previous)
