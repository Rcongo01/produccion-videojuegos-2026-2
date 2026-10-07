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

# Resultados del GlobalManager -> interfaz
signal food_changed(food_id: String)
signal placement_evaluated(food_id: String, group_id: String, correct: bool)
signal score_changed(new_score: int)

# Lab 5: una actividad externa (minijuego) produjo una recompensa
signal bonus_obtained(bonus: Dictionary)
