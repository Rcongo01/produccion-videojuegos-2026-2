# res://src/scenes/gamification/player.gd
# Lab 5: la canasta. La entrada se lee por ACCIONES (move_left / move_right), no por teclas:
# teclado, flechas o los botones táctiles de la pantalla producen la misma intención.
extends CharacterBody2D

signal collected_food

@export var speed: float = 420.0


func _ready() -> void:
	$AreaRecolect.body_entered.connect(_on_collect_area_body_entered)


func _physics_process(_delta: float) -> void:
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * speed
	move_and_slide()


func _on_collect_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("collectable"):
		collected_food.emit()
		body.queue_free()
