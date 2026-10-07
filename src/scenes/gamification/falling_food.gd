# res://src/scenes/gamification/falling_food.gd
# Lab 5: objeto recolectable con físicas. Muestra una fruta o verdura al azar
# del catálogo del GlobalManager y se destruye si toca el suelo.
extends RigidBody2D

@onready var sprite: Sprite2D = $Sprite2D

var food_id: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var options: Array = GlobalManager.foods.keys().filter(
		func(f: String) -> bool: return GlobalManager.foods[f]["group"] == "frutas_verduras")
	food_id = options.pick_random()
	sprite.texture = load(GlobalManager.food_texture_path(food_id))


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("floor"):
		queue_free()
