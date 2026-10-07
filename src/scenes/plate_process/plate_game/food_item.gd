# res://src/scenes/plate_process/plate_game/food_item.gd
# Lab 6: Máquina de Estado Finito (FSM) de un alimento arrastrable.
#
#   APARECIENDO → DISPONIBLE → ARRASTRANDO ─┬→ UBICADO      (grupo correcto, estado final)
#                     ↑                      ├→ RECHAZADO → DISPONIBLE   (grupo incorrecto)
#                     └──────────────────────┘  (se soltó fuera del plato)
#
# Cada instancia tiene su propio estado. Las animaciones (Tween) se eligen según la
# combinación previous_state → current_state, es decir, responden a la TRANSICIÓN.
extends CharacterBody2D

enum FoodState {
	APARECIENDO,
	DISPONIBLE,
	ARRASTRANDO,
	UBICADO,
	RECHAZADO,
}

@export var appear_duration: float = 0.35
@export var reject_duration: float = 0.7
@export var tray_scale: float = 0.62
@export var placed_scale: float = 0.42

@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D
@onready var lbl_name: Label = $LblName

var food_id: String = ""
var home_tray: Node2D = null
var current_state: FoodState = FoodState.APARECIENDO
var previous_state: FoodState = FoodState.APARECIENDO
var mouse_over: bool = false
var hovered_sector: Area2D = null


func _ready() -> void:
	mouse_entered.connect(func() -> void: mouse_over = true)
	mouse_exited.connect(func() -> void: mouse_over = false)
	timer.timeout.connect(_on_timer_timeout)
	sprite.texture = load(GlobalManager.food_texture_path(food_id))
	lbl_name.text = GlobalManager.foods[food_id]["name"]
	timer.start(appear_duration)
	animate_appear()


# --- Transiciones ---------------------------------------------------------------------

func change_state(next_state: FoodState) -> bool:
	var valid_transition := false
	match current_state:
		FoodState.APARECIENDO:
			valid_transition = next_state == FoodState.DISPONIBLE
		FoodState.DISPONIBLE:
			valid_transition = next_state == FoodState.ARRASTRANDO
		FoodState.ARRASTRANDO:
			valid_transition = (
				next_state == FoodState.UBICADO
				or next_state == FoodState.RECHAZADO
				or next_state == FoodState.DISPONIBLE
			)
		FoodState.RECHAZADO:
			valid_transition = next_state == FoodState.DISPONIBLE
		FoodState.UBICADO:
			valid_transition = false  # fin del ciclo de vida
	if not valid_transition:
		return false

	previous_state = current_state
	current_state = next_state
	play_transition_animation(previous_state, current_state)
	if current_state == FoodState.RECHAZADO:
		timer.start(reject_duration)
	return true


func _on_timer_timeout() -> void:
	match current_state:
		FoodState.APARECIENDO:
			change_state(FoodState.DISPONIBLE)
		FoodState.RECHAZADO:
			change_state(FoodState.DISPONIBLE)


# --- Comportamiento por estado --------------------------------------------------------

func _physics_process(delta: float) -> void:
	match current_state:
		FoodState.APARECIENDO:
			pass
		FoodState.DISPONIBLE:
			process_disponible(delta)
		FoodState.ARRASTRANDO:
			process_arrastrando(delta)
		FoodState.UBICADO:
			pass
		FoodState.RECHAZADO:
			pass


func process_disponible(_delta: float) -> void:
	# Pequeño aumento al pasar el puntero: indica que se puede tomar
	var target: float = tray_scale * (1.1 if mouse_over else 1.0)
	sprite.scale = sprite.scale.lerp(Vector2.ONE * target, 0.2)
	if mouse_over and Input.is_action_just_pressed("interact"):
		change_state(FoodState.ARRASTRANDO)


func process_arrastrando(_delta: float) -> void:
	global_position = get_global_mouse_position()
	_update_hovered_sector()
	if Input.is_action_just_released("interact"):
		release_food()


func release_food() -> void:
	var sector: Area2D = get_sector()
	_clear_hover()
	if sector == null:
		change_state(FoodState.DISPONIBLE)
		return
	# La regla vive en GlobalManager; el sector solo reacciona al resultado
	var correct: bool = GlobalManager.is_correct(food_id, sector.group_id)
	if correct and change_state(FoodState.UBICADO):
		sector.activate()
		animate_to_plate(sector.random_point_inside())
		if home_tray:
			home_tray.release()
	elif not correct:
		change_state(FoodState.RECHAZADO)
		sector.reject()
	# La interfaz comunica la jugada; GlobalManager actualiza puntaje y emite el resultado
	EventBus.food_placed.emit(food_id, sector.group_id)


func get_sector() -> Area2D:
	for area in $InteractionArea.get_overlapping_areas():
		if area.is_in_group("plate_sector"):
			return area
	return null


func _update_hovered_sector() -> void:
	var sector: Area2D = get_sector()
	if sector != hovered_sector:
		_clear_hover()
		hovered_sector = sector
		if sector:
			sector.set_highlight(true)


func _clear_hover() -> void:
	if hovered_sector and is_instance_valid(hovered_sector):
		hovered_sector.set_highlight(false)
	hovered_sector = null


func lock() -> void:
	# Usado por el controlador al terminar la partida: bloquea interacciones
	input_pickable = false
	set_physics_process(false)
	_clear_hover()


# --- Animaciones programáticas (Tween) ------------------------------------------------

func play_transition_animation(from_state: FoodState, to_state: FoodState) -> void:
	match [from_state, to_state]:
		[FoodState.APARECIENDO, FoodState.DISPONIBLE]:
			animate_appear_to_available()
		[FoodState.DISPONIBLE, FoodState.ARRASTRANDO]:
			animate_available_to_dragging()
		[FoodState.ARRASTRANDO, FoodState.DISPONIBLE]:
			animate_back_to_tray()
		[FoodState.ARRASTRANDO, FoodState.UBICADO]:
			animate_dragging_to_placed()
		[FoodState.ARRASTRANDO, FoodState.RECHAZADO]:
			animate_rejected()
		[FoodState.RECHAZADO, FoodState.DISPONIBLE]:
			animate_back_to_tray()


func animate_appear() -> void:
	sprite.scale = Vector2.ZERO
	lbl_name.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2.ONE * tray_scale, appear_duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func animate_appear_to_available() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "rotation", TAU, 0.35)
	tween.tween_property(lbl_name, "modulate:a", 1.0, 0.3)
	tween.chain().tween_property(sprite, "rotation", 0.0, 0.0)


func animate_available_to_dragging() -> void:
	z_index = 10
	lbl_name.hide()
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.25, 0.95) * tray_scale, 0.07)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.1) * tray_scale * 1.15, 0.07)
	tween.tween_property(sprite, "scale", Vector2.ONE * tray_scale * 1.15, 0.08)


func animate_back_to_tray() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", home_tray.global_position, 0.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "scale", Vector2.ONE * tray_scale, 0.2)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)
	tween.chain().tween_callback(func() -> void:
		z_index = 0
		lbl_name.show()
	)


func animate_dragging_to_placed() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 0.8) * tray_scale, 0.08)
	tween.tween_property(sprite, "scale", Vector2(0.9, 1.1) * placed_scale, 0.08)
	tween.tween_property(sprite, "scale", Vector2.ONE * placed_scale, 0.1)


func animate_to_plate(target: Vector2) -> void:
	z_index = 5
	input_pickable = false
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", target, 0.3) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "rotation", randf_range(-0.4, 0.4), 0.3)


func animate_rejected() -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color(1.0, 0.45, 0.45), 0.08)
	for i in 3:
		tween.tween_property(sprite, "rotation", 0.3, 0.06)
		tween.tween_property(sprite, "rotation", -0.3, 0.06)
	tween.tween_property(sprite, "rotation", 0.0, 0.05)
