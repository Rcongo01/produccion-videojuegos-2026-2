# res://src/core/event_bus.gd
# Lab 3: bus de eventos global (patrón Observer + Autoload "EventBus").
# Lab 4: se elimina parameter_changed y se agregan las señales del juego del plato.
extends Node

# Navegación: ahora transporta la intención de descartar la entrada anterior del historial
signal navigation_requested(target_scene: String, discard_previous: bool)

# Intenciones de la interfaz -> GlobalManager
signal next_food_requested()
signal round_restart_requested()
signal food_placed(food_id: String, group_id: String)
signal hints_toggled(enabled: bool)
signal progress_reset_requested()

# Lab 8: retroalimentación (sonido y preferencias de la experiencia de usuario)
signal sound_requested(sound_name: String)
signal sound_toggled(enabled: bool)
signal tutorial_completed()

# Lab 9: lonchera interactiva (equivalente a la pizza de la guía)
# slot: compartimento de la lonchera (0 bebida, 1 fruta, 2 principal, 3 snack); en la guía es "half"
signal ingredient_selected(ingredient_id: String, slot: int)
signal lunchbox_total_changed(new_total: int)

# Resultados del GlobalManager -> interfaz
signal food_changed(food_id: String)
signal placement_evaluated(food_id: String, group_id: String, correct: bool)
signal score_changed(new_score: int)

# Lab 5: una actividad externa (minijuego) produjo una recompensa
signal bonus_obtained(bonus: Dictionary)
