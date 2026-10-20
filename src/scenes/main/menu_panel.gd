# res://src/scenes/main/menu_panel.gd
# Lab 4: la navegación la hacen las instancias de ButtonNav (configuradas en el Inspector).
# Lab 7: muestra el progreso persistente y oculta "Salir" en la versión Web.
# Lab 8: menú decorado (fondo ilustrado + mascota Nutri). La mascota "respira" con un Tween
#        y su globo rota consejos de las Guías Alimentarias para dar vida a la pantalla.
# Lab 9: botón "Arma tu lonchera" (ButtonNav configurado en el Inspector, sin código nuevo).
extends Control

const TIP_INTERVAL := 7.0

@onready var btn_exit: Button = $HBox/VBoxMenu/HBoxSmall/BtnExit
@onready var lbl_stats: Label = $HBox/VBoxMenu/LblStats
@onready var mascot: TextureRect = $HBox/MascotColumn/Mascot
@onready var bubble: PanelContainer = $HBox/MascotColumn/Bubble
@onready var lbl_tip: Label = $HBox/MascotColumn/Bubble/LblTip

var tips: Array[String] = []
var tip_index: int = 0


func _ready() -> void:
	btn_exit.pressed.connect(func() -> void:
		get_tree().quit()
	)
	if OS.has_feature("web"):
		btn_exit.hide()
	lbl_stats.text = "Récord: %d · Lonchera: %d · Estrellas: %d · Grupos: %d / %d" % [
		GlobalManager.best_score, GlobalManager.lunch_best, GlobalManager.bonuses.size(),
		GlobalManager.groups_learned.size(), GlobalManager.groups.size()]

	tips.append("¡Hola! Soy Nutri. Te ayudo a servir un plato saludable.")
	if GlobalManager.groups_learned.size() < GlobalManager.groups.size():
		tips.append("Ya descubriste %d de 6 grupos. ¡Arma un plato para encontrar los demás!" % GlobalManager.groups_learned.size())
	tips.append("¡Prueba Lonchera Express! Los niños te esperan con sus pedidos. Ojo con los sellos negros.")
	for message in GlobalManager.GABA_MESSAGES:
		tips.append(message)

	_animate_mascot()
	var timer := Timer.new()
	timer.wait_time = TIP_INTERVAL
	timer.autostart = true
	timer.timeout.connect(_next_tip)
	add_child(timer)


func _animate_mascot() -> void:
	await get_tree().process_frame
	mascot.pivot_offset = Vector2(mascot.size.x / 2.0, mascot.size.y)
	var tween := create_tween().set_loops()
	tween.tween_property(mascot, "scale", Vector2(1.03, 0.97), 0.9).set_trans(Tween.TRANS_SINE)
	tween.tween_property(mascot, "scale", Vector2(0.98, 1.02), 0.9).set_trans(Tween.TRANS_SINE)


func _next_tip() -> void:
	tip_index = (tip_index + 1) % tips.size()
	var tween := create_tween()
	tween.tween_property(bubble, "modulate:a", 0.0, 0.25)
	tween.tween_callback(func() -> void: lbl_tip.text = tips[tip_index])
	tween.tween_property(bubble, "modulate:a", 1.0, 0.25)
