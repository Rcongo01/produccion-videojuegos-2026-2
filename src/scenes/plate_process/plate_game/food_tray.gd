# res://src/scenes/plate_process/plate_game/food_tray.gd
# Lab 6: puesto alrededor del plato donde aparece un alimento
# (equivalente a PizzaSpawn de la guía). Grupo "food_tray".
extends Node2D

@export var food_scene: PackedScene

var current_food: Node = null


func is_free() -> bool:
	return current_food == null


func spawn_food(food_id: String) -> void:
	var food = food_scene.instantiate()
	food.food_id = food_id
	food.home_tray = self
	add_child(food)
	food.global_position = global_position
	current_food = food


func release() -> void:
	current_food = null


func _draw() -> void:
	draw_circle(Vector2.ZERO, 52, Color(1, 1, 1, 0.12))
	draw_arc(Vector2.ZERO, 52, 0, TAU, 48, Color(1, 1, 1, 0.35), 2.0, true)
