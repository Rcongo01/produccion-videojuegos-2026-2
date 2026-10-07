# res://src/scenes/credits/credits_panel.gd
extends Control

@onready var btn_back: Button = $VBox/BtnBack


func _ready() -> void:
	btn_back.pressed.connect(func() -> void:
		EventBus.navigation_requested.emit("res://src/scenes/main/menu_panel.tscn")
	)
