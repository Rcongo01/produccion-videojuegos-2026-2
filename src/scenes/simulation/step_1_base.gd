# res://src/scenes/simulation/step_1_base.gd
# Lab 2: un mismo callback reutilizado con .bind() para los 6 grupos del plato.
# Lab 3: el regreso al menú se solicita al EventBus (sin rutas de cambio de escena directas).
extends Control

@onready var btn_grupo_1: Button = $VBoxContainer/GridContainer/BtnGrupo1
@onready var btn_grupo_2: Button = $VBoxContainer/GridContainer/BtnGrupo2
@onready var btn_grupo_3: Button = $VBoxContainer/GridContainer/BtnGrupo3
@onready var btn_grupo_4: Button = $VBoxContainer/GridContainer/BtnGrupo4
@onready var btn_grupo_5: Button = $VBoxContainer/GridContainer/BtnGrupo5
@onready var btn_grupo_6: Button = $VBoxContainer/GridContainer/BtnGrupo6
@onready var lbl_status_local: Label = $VBoxContainer/LblStatusLocal
@onready var btn_volver: Button = $VBoxContainer/BtnVolver


func _ready() -> void:
	# Conexiones locales del GridContainer: mismo callback, distintos parámetros
	btn_grupo_1.pressed.connect(_on_grupo_selected.bind(
		"Cereales, raíces, tubérculos y plátanos",
		"Nos dan la energía para jugar, estudiar y crecer."))
	btn_grupo_2.pressed.connect(_on_grupo_selected.bind(
		"Frutas y verduras",
		"Tienen vitaminas, minerales y fibra para una buena digestión y un corazón sano."))
	btn_grupo_3.pressed.connect(_on_grupo_selected.bind(
		"Leche y productos lácteos",
		"Aportan calcio y proteína para huesos y dientes fuertes."))
	btn_grupo_4.pressed.connect(_on_grupo_selected.bind(
		"Carnes, huevos, leguminosas, frutos secos y semillas",
		"Dan proteína, hierro y zinc para formar músculos y prevenir la anemia."))
	btn_grupo_5.pressed.connect(_on_grupo_selected.bind(
		"Grasas",
		"Dan energía y ayudan a usar algunas vitaminas. Se comen en poca cantidad."))
	btn_grupo_6.pressed.connect(_on_grupo_selected.bind(
		"Azúcares",
		"Dan energía rápida, pero se deben comer pocas veces y en poca cantidad."))

	btn_volver.pressed.connect(func() -> void:
		EventBus.navigation_requested.emit("res://src/scenes/main/menu_panel.tscn")
	)


func _on_grupo_selected(nombre_grupo: String, funcion: String) -> void:
	lbl_status_local.text = "%s\n%s" % [nombre_grupo, funcion]
	print("Grupo seleccionado de forma local: ", nombre_grupo)

