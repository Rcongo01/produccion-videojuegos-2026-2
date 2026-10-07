# res://src/scenes/plate_process/plate_game/plate.gd
# Lab 6: dibuja el Plato saludable de la Familia Colombiana y crea una división
# (PlateSector) por cada grupo, con su color y su proporción tomados del GlobalManager.
extends Node2D

@export var radius: float = 210.0
@export var sector_scene: PackedScene


func _ready() -> void:
	var angle: float = -PI / 2.0  # empieza arriba
	for group_id in GlobalManager.groups:
		var share: float = GlobalManager.groups[group_id]["plate_share"]
		var sector = sector_scene.instantiate()
		sector.name = "Sector_" + group_id
		sector.setup(group_id, radius, angle, angle + share * TAU)
		add_child(sector)
		angle += share * TAU


func _draw() -> void:
	draw_circle(Vector2(6, 10), radius + 26, Color(0, 0, 0, 0.25))  # sombra
	draw_circle(Vector2.ZERO, radius + 22, Color(0.97, 0.97, 0.95))  # borde del plato
	draw_arc(Vector2.ZERO, radius + 22, 0, TAU, 96, Color(0.8, 0.8, 0.78), 3.0, true)
