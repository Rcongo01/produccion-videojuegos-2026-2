# res://src/scenes/gamification/catch_food/spawner.gd
# Lab 5: genera recolectables de forma progresiva con un Timer y un límite máximo.
extends Node2D

signal spawned_item

@export var max_active_items: int = 4
@export var spawn_interval: float = 1.5
@export var collectable_scene: PackedScene
@export var use_parabola: bool = false
# Rango del impulso horizontal de la parábola (configurable para lanzar siempre hacia el embudo)
@export var impulse_min_x: int = -400
@export var impulse_max_x: int = 400
# Lab 9: probabilidad de ultraprocesados (el minijuego la sube con la dificultad)
@export var junk_chance: float = 0.3

@onready var timer: Timer = $Timer

var active_items: int = 0


func _ready() -> void:
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_spawn_timer_timeout)
	timer.start()


func _on_spawn_timer_timeout() -> void:
	if active_items >= max_active_items:
		return
	# Notificar al controlador del minijuego
	spawned_item.emit()
	var spawn_position := global_position
	if use_parabola:
		spawn_from_side(spawn_position, Vector2(randi_range(impulse_min_x, impulse_max_x), -250))
	else:
		spawn_item(spawn_position)


func spawn_item(spawn_position: Vector2) -> void:
	var item := collectable_scene.instantiate()
	item.set("junk_chance", junk_chance)
	item.global_position = spawn_position
	item.apply_central_impulse(Vector2(0, -100))
	get_parent().add_child(item)
	_track(item)


func spawn_from_side(spawn_position: Vector2, impulse: Vector2) -> void:
	var item := collectable_scene.instantiate()
	item.set("junk_chance", junk_chance)
	item.global_position = spawn_position
	get_parent().add_child(item)
	item.apply_central_impulse(impulse)
	_track(item)


# Lab 9: cuando un alimento se atrapa o toca el suelo libera su cupo, así siguen cayendo
# (antes cada spawner se agotaba y la partida podía quedar sin final)
func _track(item: Node) -> void:
	active_items += 1
	item.tree_exited.connect(func() -> void: active_items -= 1)
