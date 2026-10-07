# res://src/core/event_bus.gd
# Lab 3: bus de eventos global (patrón Observer + Autoload "EventBus").
extends Node

# Señal global para solicitar el cambio de pantallas del juego
signal navigation_requested(target_scene_path: String)

# Señal global para notificar la modificación de parámetros (p. ej. opciones de configuración)
signal parameter_changed(param_name: String, value: Variant)
