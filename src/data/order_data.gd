# res://src/data/order_data.gd
# Lab 9 (mejora): un pedido de "Lonchera Express". Cada niño y su pedido son un Resource editable:
# agregar un pedido nuevo es crear un .tres en src/data/orders/ y sumarlo a order_database.tres.
class_name OrderData
extends Resource

@export var id: String
@export var kid_name: String
@export var avatar: Texture2D
## Lo que pide el niño
@export_multiline var request: String
## Regla que debe cumplir la lonchera (la evalúa GlobalManager.order_fulfilled)
@export_enum("contiene", "sin_sellos", "sin_azucar", "min_puntos", "solo_saludable") var rule: String = "contiene"
## Para "contiene": ids de alimentos aceptados (basta con uno)
@export var rule_values: PackedStringArray = []
## Para "min_puntos": puntos mínimos
@export var rule_number: int = 0
## Segundos para armar la lonchera
@export var time_limit: int = 45
## Puntos extra si se cumple el pedido
@export var bonus_points: int = 30
@export_multiline var success_text: String
@export_multiline var fail_text: String
