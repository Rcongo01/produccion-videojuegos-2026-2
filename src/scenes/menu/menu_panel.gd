# res://menu_panel.gd
extends Control

# Captura de nodos hijos en caché tras cargarse el SceneTree
@onready var btn_simular: Button = $VBoxMenu/BtnIniciar
@onready var btn_salir: Button = $VBoxMenu/BtnSalir
@onready var lbl_estado: Label = $VBoxMenu/LblTitle

func _ready() -> void:
	# Imprime mensaje técnico de éxito en la consola de depuración
	print("Sistema interactivo de inicio cargado correctamente.")
	
	# Conexión local de eventos (Signals) mediante código
	btn_simular.pressed.connect(_on_btn_simular_pressed)
	btn_salir.pressed.connect(_on_btn_salir_pressed)

# Funciones Callback locales para reaccionar a la interacción física
func _on_btn_simular_pressed() -> void:
	lbl_estado.text = "Estado del Sistema: Cargando simulación..."
	print("Simulación iniciada de forma local.")

func _on_btn_salir_pressed() -> void:
	get_tree().quit()
