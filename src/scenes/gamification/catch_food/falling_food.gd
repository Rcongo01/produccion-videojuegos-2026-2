# res://src/scenes/gamification/catch_food/falling_food.gd
# Lab 5: objeto recolectable con físicas que se destruye si toca el suelo.
# Lab 9 (mejora "Atrapa lo saludable"): puede ser una fruta o verdura (del Plato saludable) o un
# ultraprocesado tomado del catálogo de Resources (IngredientData con healthy = false), con su sello.
extends RigidBody2D

## Probabilidad de que caiga un ultraprocesado (la fija el spawner)
@export var junk_chance: float = 0.3

@onready var sprite: Sprite2D = $Sprite2D
@onready var seal: Sprite2D = $Seal

var food_id: String = ""
var display_name: String = ""
var healthy: bool = true


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var junk: Array = GlobalManager.ingredients.filter(func(i: IngredientData) -> bool: return not i.healthy)
	if randf() < junk_chance and not junk.is_empty():
		var item: IngredientData = junk.pick_random()
		healthy = false
		food_id = item.id
		display_name = item.display_name
		sprite.texture = item.icon
		if not item.seals.is_empty():
			seal.texture = GlobalManager.seal_texture(item.seals[0])
			seal.show()
	else:
		var options: Array = GlobalManager.foods.keys().filter(
			func(f: String) -> bool: return GlobalManager.foods[f]["group"] == "frutas_verduras")
		food_id = options.pick_random()
		display_name = GlobalManager.foods[food_id]["name"]
		sprite.texture = load(GlobalManager.food_texture_path(food_id))


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("floor"):
		queue_free()
