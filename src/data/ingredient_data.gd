# res://src/data/ingredient_data.gd
# Lab 9: un alimento de la lonchera representado como Resource (contenido separado del código).
# Cada archivo .tres de src/data/ingredients/ es una instancia editable desde el Inspector.
class_name IngredientData
extends Resource

## Identificador sin espacios (se guarda en GlobalManager.lunchbox_selection)
@export var id: String
## Nombre que ve el niño
@export var display_name: String
## Imagen del compartimento de la lonchera con este alimento
@export var texture: Texture2D
## "Precio" de la guía = puntos saludables que suma a la lonchera
@export var price: int

@export_group("Lonchera Express")
## Compartimento de la lonchera donde va este alimento
@export_enum("bebida", "fruta", "principal", "snack") var kind: String = "fruta"
## false para ultraprocesados y comida rápida
@export var healthy: bool = true
## Sellos de advertencia del empaque: "azucares", "sodio", "grasas"
@export var seals: PackedStringArray = []

@export_group("Presentación y contenido")
## Reto 3: ícono pequeño para el botón de la lista (distinto de la textura de la lonchera)
@export var icon: Texture2D
## Grupo del Plato saludable al que pertenece ("" si no pertenece a ninguno, como el agua)
@export var group_id: String
## Consejo que muestra Nutri al elegirlo
@export_multiline var tip: String
