# res://src/scenes/main/menu_panel.gd
# Lab 4: la navegación la hacen las instancias de ButtonNav (configuradas en el Inspector).
# Lab 7: muestra el progreso persistente y oculta "Salir" en la versión Web
# (en un navegador la página no se puede cerrar desde el juego).
extends Control

@onready var btn_exit: Button = $HBox/VBoxMenu/HBoxSmall/BtnExit
@onready var lbl_stats: Label = $HBox/VBoxMenu/LblStats


func _ready() -> void:
	btn_exit.pressed.connect(func() -> void:
		get_tree().quit()
	)
	if OS.has_feature("web"):
		btn_exit.hide()
	lbl_stats.text = "Récord: %d · Estrellas: %d · Grupos descubiertos: %d / %d" % [
		GlobalManager.best_score, GlobalManager.bonuses.size(),
		GlobalManager.groups_learned.size(), GlobalManager.groups.size()]
