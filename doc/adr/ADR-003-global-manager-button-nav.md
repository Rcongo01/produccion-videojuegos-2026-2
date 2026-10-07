# Registro de Decisión de Arquitectura (ADR)

## ADR-003: Gestión de Estado Global y Componentes de Navegación Reutilizables

* **Estado:** Aprobado
* **Fecha:** 2026-10-03
* **Autor:** Ronaldo Congo Cancelado

### Contexto

El juego necesita información compartida entre pantallas: los 6 grupos del Plato saludable de la Familia Colombiana (nombre, color, función, importancia, mensaje GABA asociado), el catálogo de alimentos, la ronda en curso y el puntaje. Si el puntaje viviera en la pantalla del juego, se perdería al volver al menú, porque `MainApp` destruye la escena. Además, varios botones repetían el mismo código de navegación.

### Decisión

* Implementar `GlobalManager` como Autoload. Contiene los **datos** (`groups`, `foods`, `GABA_MESSAGES`, `round_composition`, `points`) y el **estado** (`selection`, `round_deck`, `current_score`, `settings`).
* La interfaz y `GlobalManager` se comunican solo por el `EventBus`:
  * Interfaz → manager: `next_food_requested`, `food_placed`, `round_restart_requested`, `hints_toggled`.
  * Manager → interfaz: `food_changed`, `placement_evaluated`, `score_changed`.
* Crear `ButtonNav` (escena reutilizable con `@export_file target_scene` y `@export discard_previous`). `MainApp` mantiene `navigation_history` como pila (`append` / `pop_back`).

### Consecuencias

* **Positivas:**
  * El puntaje y la ronda sobreviven a la navegación.
  * Los datos del plato están en un único lugar; cambiar un texto o un alimento no toca la interfaz.
  * La interfaz no conoce las reglas: no sabe cómo se evalúa ni cómo se calcula el puntaje.
  * Configuración y Créditos quedaron casi sin código; Créditos ya no necesita script.
* **Negativas / Costos:**
  * Seguir una acción exige recorrer interfaz → EventBus → GlobalManager → EventBus → interfaz.
  * `GlobalManager` concentra muchas responsabilidades y debe vigilarse para que no crezca sin control.
