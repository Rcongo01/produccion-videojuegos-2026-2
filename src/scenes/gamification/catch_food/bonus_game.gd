# res://src/scenes/gamification/catch_food/bonus_game.gd
# Lab 5: controlador del minijuego. Lleva el conteo, decide victoria/derrota y publica la
# recompensa en el EventBus sin conocer el resumen del plato ni el proceso principal del juego.
# Lab 9 (mejora "Atrapa lo saludable"): también caen gaseosas y ultraprocesados. Atraparlos quita
# una vida; el juego se acelera con cada 3 aciertos y ganar sin perder vidas da una estrella dorada.
extends Node2D

@export var target_items: int = 10
@export var max_spawned_items: int = 30
@export var max_lives: int = 3
@export var bonus_value: int = 30
@export var perfect_bonus_value: int = 40
@export var bonus_minimum_score: int = 60
@export var speed_up_every: int = 3

const HEART := preload("res://src/scenes/gamification/catch_food/assets/heart.png")
const HEART_EMPTY := preload("res://src/scenes/gamification/catch_food/assets/heart_empty.png")

@onready var objective: Label = $CanvasLayer/Objective
@onready var result_panel: Control = $CanvasLayer/ResultPanel
@onready var result_label: Label = $CanvasLayer/ResultPanel/VBox/ResultLabel
@onready var btn_left: Button = $CanvasLayer/TouchLeft
@onready var btn_right: Button = $CanvasLayer/TouchRight
@onready var hearts: Array[TextureRect] = [$CanvasLayer/Lives/Heart1, $CanvasLayer/Lives/Heart2, $CanvasLayer/Lives/Heart3]
@onready var flash: ColorRect = $CanvasLayer/Flash
@onready var float_layer: Node2D = $FloatLayer

var current_spawned_items: int = 0
var collected_items: int = 0
var lives: int = 3
var junk_caught: int = 0
var game_finished: bool = false


# Spawners de ESTA escena (la anterior puede seguir un fotograma en el árbol tras queue_free)
func _my_spawners() -> Array:
	return get_tree().get_nodes_in_group("spawner").filter(func(n: Node) -> bool: return is_ancestor_of(n))


func _ready() -> void:
	lives = max_lives
	var spawners: Array = _my_spawners()
	for spawn in spawners:
		spawn.spawned_item.connect(_on_item_spawned)
	_update_objective()
	_update_hearts()
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


func _on_player_collected_food(healthy: bool = true, food_name: String = "", at: Vector2 = Vector2.ZERO) -> void:
	if game_finished:
		return
	if healthy:
		collected_items += 1
		EventBus.sound_requested.emit("correct")
		_float_text("+1", at, Color(0.55, 0.95, 0.45))
		_update_objective()
		if collected_items % speed_up_every == 0:
			_speed_up()
		if collected_items >= target_items:
			win_game()
	else:
		lives -= 1
		junk_caught += 1
		EventBus.sound_requested.emit("wrong")
		_float_text("¡Ups! %s" % food_name, at, Color(1.0, 0.45, 0.45))
		_update_hearts()
		_flash_screen()
		if lives <= 0:
			lose_game()


# Dificultad progresiva: caen más rápido y aparecen más ultraprocesados
func _speed_up() -> void:
	for spawn in _my_spawners():
		spawn.timer.wait_time = max(spawn.timer.wait_time * 0.88, 0.7)
		spawn.junk_chance = min(spawn.junk_chance + 0.04, 0.4)
	_float_text("¡Más rápido!", Vector2(640, 260), Color(0.95, 0.76, 0.31))


func _update_objective() -> void:
	objective.text = "Frutas y verduras: %d / %d" % [collected_items, target_items]


func _update_hearts() -> void:
	for i in hearts.size():
		hearts[i].texture = HEART if i < lives else HEART_EMPTY
	if lives < max_lives and lives >= 0 and lives < hearts.size():
		var lost := hearts[lives]
		lost.pivot_offset = lost.size / 2.0
		lost.scale = Vector2(1.6, 1.6)
		create_tween().tween_property(lost, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK)


func _flash_screen() -> void:
	var tween := create_tween()
	tween.tween_property(flash, "color:a", 0.35, 0.06)
	tween.tween_property(flash, "color:a", 0.0, 0.3)


func _float_text(text: String, at: Vector2, color: Color) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 30)
	label.add_theme_color_override("font_color", color)
	label.add_theme_constant_override("outline_size", 8)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.8))
	label.position = at + Vector2(-60, -70)
	float_layer.add_child(label)
	var tween := label.create_tween().set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 70, 0.8)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.3)
	tween.chain().tween_callback(label.queue_free)


func win_game() -> void:
	if game_finished:
		return
	clean_game()
	var perfect := lives == max_lives
	var value := perfect_bonus_value if perfect else bonus_value
	var bonus: Dictionary = {
		"value": value,
		"minimum_score": bonus_minimum_score,
	}
	EventBus.bonus_obtained.emit(bonus)
	EventBus.sound_requested.emit("win")
	result_label.text = "%s\n+%d puntos para un plato o una lonchera de al menos %d puntos.\n\n%s" % [
		"¡Perfecto! Ganaste una estrella dorada sin tocar ningún ultraprocesado." if perfect else "¡Ganaste una estrella!",
		value, bonus_minimum_score, GlobalManager.GABA_MESSAGES[2]]
	result_panel.show()


func lose_game() -> void:
	if game_finished:
		return
	clean_game()
	EventBus.sound_requested.emit("lose")
	if lives <= 0:
		result_label.text = "Atrapaste demasiados ultraprocesados.\nFíjate en los sellos negros y esquívalos.\n¡Inténtalo otra vez!"
	else:
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
