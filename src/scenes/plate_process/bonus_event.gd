# res://src/scenes/plate_process/bonus_event.gd
# Lab 5: pantalla de participación voluntaria en el minijuego de bonificación.
extends Control

@onready var lbl_bonuses: Label = $Card/VBox/LblBonuses


func _ready() -> void:
	lbl_bonuses.text = "Estrellas guardadas: %d" % GlobalManager.bonuses.size()
