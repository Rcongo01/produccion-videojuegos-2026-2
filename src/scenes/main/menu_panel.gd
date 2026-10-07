# res://src/scenes/main/menu_panel.gd
# Lab 2: referencias con @onready y señales conectadas por código (.connect()).
extends Control

# Captura de nodos hijos en caché tras cargarse el SceneTree
@onready var btn_iniciar: Button = $VBoxMenu/BtnIniciar
@onready var btn_creditos: Button = $VBoxMenu/BtnCreditos
@onready var btn_salir: Button = $VBoxMenu/BtnSalir
@onready var lbl_estado: Label = $VBoxMenu/LblTitle
@onready var panel_creditos: PanelContainer = $PanelCreditos
@onready var btn_cerrar_creditos: Button = $PanelCreditos/VBox/BtnCerrarCreditos


func _ready() -> void:
	print("Mi Plato Saludable: menú inicial cargado correctamente.")
	# Conexión local de eventos (Signals) mediante código
	btn_iniciar.pressed.connect(_on_btn_iniciar_pressed)
	btn_creditos.pressed.connect(_on_btn_creditos_pressed)
	btn_cerrar_creditos.pressed.connect(_on_btn_cerrar_creditos_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)


func _on_btn_iniciar_pressed() -> void:
	lbl_estado.text = "Cargando el plato..."
	# Navegación acoplada heredada (se refactoriza en el Lab 3 con EventBus)
	get_tree().change_scene_to_file("res://src/scenes/simulation/step_1_base.tscn")


# Experimento de la Parte 9: pop-up de créditos mostrado/ocultado con señales
func _on_btn_creditos_pressed() -> void:
	panel_creditos.show()


func _on_btn_cerrar_creditos_pressed() -> void:
	panel_creditos.hide()


func _on_btn_salir_pressed() -> void:
	get_tree().quit()
