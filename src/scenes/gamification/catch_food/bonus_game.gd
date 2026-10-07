# res://src/scenes/gamification/catch_food/bonus_game.gd
# Lab 5: controlador del minijuego "Atrapa frutas y verduras".
# Lleva el conteo, decide victoria/derrota y publica la recompensa en el EventBus
# sin conocer el resumen del plato ni el proceso principal del juego.
extends Node2D

@export var target_items: int = 8
@export var max_spawned_items: int = 18
@export var bonus_value: int = 30
@export var bonus_minimum_score: int = 60

@onready var objective: Label = $CanvasLayer/Objective
@onready var result_panel: Control = $CanvasLayer/ResultPanel
@onready var result_label: Label = $CanvasLayer/ResultPanel/VBox/ResultLabel
@onready var btn_left: Button = $CanvasLayer/TouchLeft
@onready var btn_right: Button = $CanvasLayer/TouchRight

var current_spawned_items: int = 0
var collected_items: int = 0
var game_finished: bool = false


# Spawners de ESTA escena (la anterior puede seguir un fotograma en el árbol tras queue_free)
func _my_spawners() -> Array:
	return get_tree().get_nodes_in_group("spawner").filter(func(n: Node) -> bool: return is_ancestor_of(n))


func _ready() -> void:
	var spawners: Array = _my_spawners()
	for spawn in spawners:
		spawn.spawned_item.connect(_on_item_spawned)
	_update_objective()
	# Entrada táctil: los botones presionan las mismas acciones del Input Map
	btn_left.button_down.connect(Input.action_press.bind("move_left"))
	btn_left.button_up.connect(Input.action_release.bind("move_left"))
	btn_right.button_down.connect(Input.action_press.bind("move_right"))
	btn_right.button_up.connect(Input.action_release.bind("move_right"))


func _exit_tree() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")


func _on_item_spawned() -> void:
	current_spawned_items += 1
	if current_spawned_items > max_spawned_items:
		lose_game()


func _on_player_collected_food() -> void:
	collected_items += 1
	_update_objective()
	if collected_items >= target_items:
		win_game()


func _update_objective() -> void:
	objective.text = "Frutas y verduras: %d / %d" % [collected_items, target_items]


func win_game() -> void:
	if game_finished:
		return
	clean_game()
	var bonus: Dictionary = {
		"value": bonus_value,
		"minimum_score": bonus_minimum_score,
	}
	EventBus.bonus_obtained.emit(bonus)
	result_label.text = "¡Ganaste una estrella!\n+%d puntos para un plato de al menos %d puntos.\n\n%s" % [
		bonus_value, bonus_minimum_score, GlobalManager.GABA_MESSAGES[2]]
	result_panel.show()


func lose_game() -> void:
	if game_finished:
		return
	clean_game()
	result_label.text = "Esta vez no ganaste la estrella.\n¡Inténtalo otra vez!"
	result_panel.show()


func clean_game() -> void:
	if game_finished:
		return
	game_finished = true
	var spawners: Array = _my_spawners()
	for spawn in spawners:
		spawn.queue_free()
	$Player.queue_free()
	btn_left.hide()
	btn_right.hide()
